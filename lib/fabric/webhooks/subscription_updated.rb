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

        subscription.sync_with(stripe_subscription)
        sub_items = subscription.subscription_items
        stripe_subscription.items.data.each do |sub_item|
          item = sub_items.find_by(stripe_id: sub_item.id) || sub_items.build
          item.sync_with(sub_item)
          item.save
        end
        saved = subscription.save
        Fabric.config.logger.info "SubscriptionUpdated: Updated subscription: "\
          "#{subscription.id} saved: #{saved}"
      end

    end
  end
end
