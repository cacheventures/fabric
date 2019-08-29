module Fabric
  module Webhooks
    class SetupIntentCreated
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
        setup_intent = Fabric::SetupIntent.new
        setup_intent.sync_with(stripe_setup_intent)
        saved = setup_intent.save
        log_data = {
          class: self.class.name, setup_intent: setup_intent.stripe_id,
          saved: saved
        }
        flogger.json_info 'Created', log_data
      end
    end
  end
end
