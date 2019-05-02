module Fabric
  module Webhooks
    class SubscriptionCreated
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
        customer = retrieve_local(:customer, stripe_subscription.customer)
        subscription = Fabric::Subscription.new(customer: customer)
        saved = Fabric.sync_and_save_subscription_and_items(
          subscription, stripe_subscription
        )

        Fabric.config.logger.info "SubscriptionCreated: Created subscription: "\
          "#{subscription.stripe_id} saved: #{saved}"
      end
    end
  end
end
