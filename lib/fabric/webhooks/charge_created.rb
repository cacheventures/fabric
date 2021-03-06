module Fabric
  module Webhooks
    class ChargeCreated
      include Fabric::Webhook

      def call(event)
        check_idempotence(event) or return if Fabric.config.store_events
        stripe_charge = retrieve_resource(
          'charge', event['data']['object']['id']
        )
        return if stripe_charge.nil?

        handle(event, stripe_charge)
        persist_model(stripe_charge) if Fabric.config.persist?(:charge)
      end

      def persist_model(stripe_charge)
        customer = retrieve_local(:customer, stripe_charge.customer)
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
