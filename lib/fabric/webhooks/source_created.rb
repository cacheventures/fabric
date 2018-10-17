module Fabric
  module Webhooks
    class SourceCreated
      include Fabric::Webhook

      def call(event)
        check_idempotency(event) or return if Fabric.config.store_events
        persist_model(event) if Fabric.config.persist?(:source)
        handle(event)
      end

      def persist_model(event)
        stripe_source = event.data.object
        customer = retrieve_local(:customer, stripe_source.customer)
        return unless customer

        source = Fabric::Card.new(customer: customer)
        source.sync_with(stripe_source)
        saved = source.save
        Fabric.config.logger.info "SourceCreated: Created source: "\
          "#{source.stripe_id} saved: #{saved}"
      end

    end
  end
end
