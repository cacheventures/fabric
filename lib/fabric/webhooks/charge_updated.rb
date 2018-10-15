module Fabric
  module Webhooks
    class ChargeUpdated
      include Fabric::Webhook

      def call(event)
        if Fabric.config.store_events
          check_idempotency(event) or return
        end

        persist_model(event) if Fabric.config.persist?(:charge)

        handle(event)
      end

      def persist_model(event)
        stripe_charge = event.data.object
        charge = Fabric::Invoice.find_by(
          stripe_id: stripe_charge.id
        )
        if charge.present?
          charge.sync_with(stripe_charge)
          saved = charge.save
          Fabric.config.logger.info "ChargeUpdated: Updated charge: "\
            "#{stripe_charge.id} saved: #{saved}"
        else
          Fabric.config.logger.info "ChargeUpdated: Unable to locate "\
            "charge. charge: #{stripe_charge.id}"
        end
      end

    end
  end
end
