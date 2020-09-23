module Fabric
  module Webhooks
    class PaymentIntentCreated
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
        payment_intent = Fabric::PaymentIntent.new
        payment_intent.sync_with(stripe_payment_intent)
        saved = payment_intent.save

        Fabric.config.logger.info "PaymentIntentCreated: Created payment "\
          "intent: #{payment_intent.stripe_id} saved: #{saved}"
      end
    end
  end
end
