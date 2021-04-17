module Fabric
  module Webhooks
    class PaymentIntentCanceled
      include Fabric::Webhook

      def call(event)
        check_idempotence(event) or return if Fabric.config.store_events
        handle(event)
        persist_model(event) if Fabric.config.persist?(:payment_intent)
      end

      def persist_model(event)
        payment_intent = retrieve_local(
          :payment_intent, event['data']['object']['id']
        )
        return unless payment_intent

        payment_intent.destroy
        Fabric.config.logger.info "PaymentIntentCanceled: Deleting payment_intent: "\
          "#{payment_intent.stripe_id}"
      end

    end
  end
end
