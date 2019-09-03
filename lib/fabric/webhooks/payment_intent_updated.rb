module Fabric
  module Webhooks
    class PaymentIntentUpdated
      include Fabric::Webhook

      def call(event)
        check_idempotence(event) or return if Fabric.config.store_events
        stripe_payment_intent = retrieve_resource(
          'payment_intent', event['data']['object']['id']
        )
        return if stripe_payment_intent.nil?

        handle(event, stripe_payment_intent)
        if Fabric.config.persist?(:payment_intent)
          persist_model(stripe_payment_intent)
        end
      end

      def persist_model(stripe_payment_intent)
        payment_intent = retrieve_local(
          :payment_intent, stripe_payment_intent.id
        )
        return unless payment_intent

        payment_intent.sync_with(stripe_payment_intent)
        saved = payment_intent.save

        log_data = {
          class: self.class.name, payment_intent: payment_intent.stripe_id,
          saved: saved
        }
        flogger.json_info 'Succeeded', log_data
      end
    end
  end
end
