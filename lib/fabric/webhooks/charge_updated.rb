module Fabric
  module Webhooks
    class ChargeUpdated
      include Fabric::Webhook

      def call(event)
        check_idempotency(event) or return if Fabric.config.store_events
        stripe_charge = retrieve_resource(
          'charge', event['data']['object']['id']
        )
        return if stripe_charge.nil?

        handle(event, stripe_charge)
        persist_model(stripe_charge) if Fabric.config.persist?(:charge)
      end

      def persist_model(stripe_charge)
        charge = retrieve_local(:charge, stripe_charge.id)
        return unless charge

        charge.sync_with(stripe_charge)
        saved = charge.save
        Fabric.config.logger.info "ChargeUpdated: Updated charge: "\
          "#{charge.stripe_id} saved: #{saved}"
      end
    end
  end
end
