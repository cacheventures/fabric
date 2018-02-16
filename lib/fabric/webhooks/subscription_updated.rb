module Fabric
  module Webhooks
    class SubscriptionUpdated
      include Fabric::Webhook

      def call(event)
        if Fabric.config.store_events
          check_idempotency(event) or return
        end

        persist_model(event) if Fabric.config.persist_models

        handle(event)
      end

      def persist_model(event)
        stripe_subscription = event.data.object
        subscription = Fabric::Subscription.find_by(
          stripe_id: stripe_subscription.id
        )
        if subscription.present?
          subscription.sync_with(stripe_subscription)
          saved = subscription.save
          Fabric.config.logger.info "SubscriptionUpdated: Updated subscription: "\
            "#{stripe_subscription.id} saved: #{saved}"
        else
          Fabric.config.logger.info "SubscriptionUpdated: Unable to locate "\
            "subscription. subscription: #{stripe_subscription.id}"
        end
      end

    end
  end
end
