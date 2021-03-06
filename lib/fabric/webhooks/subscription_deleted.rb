module Fabric
  module Webhooks
    class SubscriptionDeleted
      include Fabric::Webhook

      def call(event)
        check_idempotence(event) or return if Fabric.config.store_events
        handle(event)
        persist_model(event) if Fabric.config.persist?(:subscription)
      end

      def persist_model(event)
        stripe_subscription = event['data']['object']
        subscription = retrieve_local(:subscription, stripe_subscription['id'])
        return unless subscription

        subscription.destroy
        Fabric.config.logger.info "SubscriptionDeleted: Deleting subscription:"\
          " #{subscription.id}"
      end
    end
  end
end
