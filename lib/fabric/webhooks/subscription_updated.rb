module Fabric
  module Webhooks
    class SubscriptionUpdated
      include Fabric::Webhook

      def call(event)
        check_idempotence(event) or return if Fabric.config.store_events
        stripe_subscription = retrieve_resource(
          'subscription', event['data']['object']['id']
        )
        return if stripe_subscription.nil?

        handle(event, stripe_subscription)
        if Fabric.config.persist?(:subscription)
          persist_model(stripe_subscription)
        end
      end

      def persist_model(stripe_subscription)
        subscription = retrieve_local(:subscription, stripe_subscription.id)
        return unless subscription

        saved = Fabric.sync_and_save_subscription_and_items(
          subscription, stripe_subscription
        )

        Fabric.config.logger.info "SubscriptionUpdated: Updated subscription: "\
          "#{subscription.id} saved: #{saved}"
      end
    end
  end
end
