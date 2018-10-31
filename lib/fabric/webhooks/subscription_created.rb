module Fabric
  module Webhooks
    class SubscriptionCreated
      include Fabric::Webhook

      def call(event)
        check_idempotency(event) or return if Fabric.config.store_events
        stripe_subscription = Stripe::Subscription.retrieve(
          event['data']['object']['id']
        )
        handle(event, stripe_subscription)
        if Fabric.config.persist?(:subscription)
          persist_model(stripe_subscription)
        end
      end

      def persist_model(stripe_subscription)
        customer = retrieve_local(:customer, stripe_subscription.customer)
        subscription = Fabric::Subscription.new(customer: customer)
        subscription.sync_with(stripe_subscription)
        saved = subscription.save
        Fabric.config.logger.info "SubscriptionCreated: Created subscription: "\
          "#{subscription.stripe_id} saved: #{saved}"
      end
    end
  end
end
