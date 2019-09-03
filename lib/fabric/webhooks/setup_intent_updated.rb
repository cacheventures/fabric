# Stripe doesn't actually have a setup_intent.updated webhook, but this makes
# sense because setup_failed and succeeded webhooks both just update it.
module Fabric
  module Webhooks
    class SetupIntentUpdated
      include Fabric::Webhook

      def call(event)
        check_idempotence(event) or return if Fabric.config.store_events
        stripe_setup_intent = retrieve_resource(
          'setup_intent', event['data']['object']['id']
        )
        return if stripe_setup_intent.nil?

        handle(event, stripe_setup_intent)
        if Fabric.config.persist?(:setup_intent)
          persist_model(stripe_setup_intent)
        end
      end

      def persist_model(stripe_setup_intent)
        setup_intent = retrieve_local(:setup_intent, stripe_setup_intent.id)
        return unless setup_intent

        setup_intent.sync_with(stripe_setup_intent)
        saved = setup_intent.save

        log_data = {
          class: self.class.name, setup_intent: setup_intent.stripe_id,
          saved: saved
        }
        flogger.json_info 'Updated', log_data
      end
    end
  end
end
