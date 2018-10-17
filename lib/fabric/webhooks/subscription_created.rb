module Fabric
  module Webhooks
    class SubscriptionCreated
      include Fabric::Webhook

      def call(event)
        check_idempotency(event) or return if Fabric.config.store_events
        persist_model(event) if Fabric.config.persist?(:subscription)
        handle(event)
      end

      def persist_model(event)
        stripe_subscription = event.data.object
        customer = retrieve_local(:customer, stripe_subscription.customer)

        subscription = Fabric::Subscription.new(customer: customer)
        subscription.sync_with(event.data.object)
        saved = subscription.save
        Fabric.config.logger.info "SubscriptionCreated: Created subscription: "\
          "#{subscription.stripe_id} saved: #{saved}"
      end

    end
  end
end
