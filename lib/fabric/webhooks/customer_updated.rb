module Fabric
  module Webhooks
    class CustomerUpdated
      include Fabric::Webhook

      def call(event)
        check_idempotency(event) or return if Fabric.config.store_events
        persist_model(event) if Fabric.config.persist?(:customer)
        handle(event)
      end

      def persist_model(event)
        stripe_customer = event.data.object
        customer = retrieve_local(:customer, stripe_customer.id)
        return unless customer
        return unless most_recent_update?(customer, event)

        customer.sync_with(stripe_customer)
        saved = customer.save
        Fabric.config.logger.info "CustomerUpdated: Updated customer: "\
          "#{customer.stripe_id} saved: #{saved}"
      end

    end
  end
end
