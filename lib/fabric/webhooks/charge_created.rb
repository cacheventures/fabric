module Fabric
  module Webhooks
    class ChargeCreated
      include Fabric::Webhook

      def call(event)
        check_idempotency(event) or return if Fabric.config.store_events
        persist_model(event) if Fabric.config.persist?(:charge)
        handle(event)
      end

      def persist_model(event)
        stripe_charge = event.data.object
        customer = retrieve_resource(:customer, stripe_charge.customer)
        return unless customer

        charge = Fabric::Charge.new(customer: customer)
        charge.sync_with(stripe_charge)
        saved = charge.save
        Fabric.config.logger.info "ChargeCreated: Created charge: "\
          "#{charge.stripe_id} saved: #{saved}"
      end
    end
  end
end
