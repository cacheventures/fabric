module Fabric
  module Webhooks
    class PaymentMethodAttached
      include Fabric::Webhook

      def call(event)
        check_idempotence(event) or return if Fabric.config.store_events
        stripe_payment_method = retrieve_resource(
          'payment_method', event['data']['object']['id']
        )
        return if stripe_payment_method.nil?

        handle(event, stripe_payment_method)
        if Fabric.config.persist?(:payment_method)
          persist_model(stripe_payment_method)
        end
      end

      def persist_model(stripe_payment_method)
        payment_method = Fabric::PaymentMethod.new
        payment_method.sync_with(stripe_payment_method)
        saved = payment_method.save

        log_data = {
          class: self.class.name, payment_method: payment_method.stripe_id,
          saved: saved
        }
        flogger.json_info 'Created', log_data
      end
    end
  end
end
