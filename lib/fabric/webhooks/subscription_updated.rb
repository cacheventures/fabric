module Fabric
  module Webhooks
    class SubscriptionUpdated
      include Fabric::Webhook

      def call(event)
        check_idempotency(event) or return if Fabric.config.store_events
        persist_model(event) if Fabric.config.persist?(:subscription)
        handle(event)
      end

      def persist_model(event)
        stripe_subscription = event.data.object
        subscription = retrieve_local(:subscription, stripe_subscription.id)
        return unless subscription
        return unless most_recent_update?(subscription, event)

        saved = Fabric.sync_and_save_subscription_and_items(
          subscription, stripe_subscription
        )

        Fabric.config.logger.info "SubscriptionUpdated: Updated subscription: "\
          "#{subscription.id} saved: #{saved}"
      end

    end
  end
end
