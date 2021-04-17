module Fabric
  module Webhooks
    class SetupIntentCanceled
      include Fabric::Webhook

      def call(event)
        check_idempotence(event) or return if Fabric.config.store_events
        handle(event)
        persist_model(event) if Fabric.config.persist?(:setup_intent)
      end

      def persist_model(event)
        setup_intent = retrieve_local(
          :setup_intent, event['data']['object']['id']
        )
        return unless setup_intent

        setup_intent.destroy
        Fabric.config.logger.info "SetupIntentCanceled: Deleting setup intent: "\
          "#{setup_intent.stripe_id}"
      end

    end
  end
end
