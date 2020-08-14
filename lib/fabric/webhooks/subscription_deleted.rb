module Fabric
  module Webhooks
    class SubscriptionDeleted
      include Fabric::Webhook

      def call(event)
        check_idempotence(event) or return if Fabric.config.store_events
        stripe_subscription = retrieve_resource(
          'subscription', event['data']['object']['id']
        )
        return if stripe_subscription.nil?

        handle(event)
        return unless Fabric.config.persist?(:subscription)

        persist_model(stripe_subscription)
      end

      def persist_model(stripe_subscription)
        subscription = retrieve_local(:subscription, stripe_subscription.id)
        return unless subscription

        subscription.destroy
        Fabric.config.logger.info "SubscriptionDeleted: Deleting subscription:"\
          " #{subscription.id}"
      end
    end
  end
end
