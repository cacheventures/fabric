module Fabric
  module Webhooks
    class ChargeUpdated
      include Fabric::Webhook

      def call(event)
        check_idempotency(event) or return if Fabric.config.store_events
        persist_model(event) if Fabric.config.persist?(:charge)
        handle(event)
      end

      def persist_model(event)
        stripe_charge = event.data.object
        charge = retrieve_local(:charge, stripe_charge.id)
        return unless charge
        return unless most_recent_update?(charge, event)

        charge.sync_with(stripe_charge)
        saved = charge.save
        Fabric.config.logger.info "ChargeUpdated: Updated charge: "\
          "#{charge.stripe_id} saved: #{saved}"
      end
    end
  end
end
