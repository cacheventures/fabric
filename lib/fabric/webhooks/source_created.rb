module Fabric
  module Webhooks
    class SourceCreated
      include Fabric::Webhook

      def call(event)
        if Fabric.config.store_events
          check_idempotency(event) or return
        end

        persist_model(event) if Fabric.config.persist?(:source)

        handle(event)
      end

      def persist_model(event)
        customer_id = event.try(:data).try(:object).try(:customer)
        if customer_id.present?
          customer = Fabric::Customer.find_by(stripe_id: customer_id)
          unless customer.present?
            Fabric.config.logger.info 'SourceCreated: No matching customer.'
            return
          end
        else
          Fabric.config.logger.info 'SourceCreated: ERROR: No customer.'
          return
        end

        source = Fabric::Card.new(
          customer: customer
        )
        source.sync_with(event.data.object)
        saved = source.save
        Fabric.config.logger.info "SourceCreated: Created source: "\
          "#{source.stripe_id} saved: #{saved}"
      end

    end
  end
end
