module Fabric
  module Webhooks
    class ChargeCreated
      include Fabric::Webhook

      def call(event)
        if Fabric.config.store_events
          check_idempotency(event) or return
        end

        persist_model(event) if Fabric.config.persist?(:charge)

        handle(event)
      end

      def persist_model(event)
        customer_id = event.try(:data).try(:object).try(:customer)
        if customer_id.present?
          customer = Fabric::Customer.find_by(stripe_id: customer_id)
          unless customer.present?
            Fabric.config.logger.info 'ChargeCreated: No matching customer.'
            return
          end
        else
          Fabric.config.logger.info 'ChargeCreated: ERROR: No customer.'
          return
        end

        charge = Fabric::Charge.new(
          customer: customer
        )
        charge.sync_with(event.data.object)
        saved = charge.save
        Fabric.config.logger.info "ChargeCreated: Created charge: "\
          "#{charge.stripe_id} saved: #{saved}"
      end
    end
  end
end
