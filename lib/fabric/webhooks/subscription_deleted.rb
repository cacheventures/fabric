module Fabric
  module Webhooks
    class SubscriptionDeleted
      include Fabric::Webhook

      def call(event)
        if Fabric.config.store_events
          check_idempotency(event) or return
        end

        persist_model(event) if Fabric.config.persist?(:subscription)

        handle(event)
      end

      def persist_model(event)
        stripe_subscription = event.data.object
        subscription = Fabric::Subscription.find_by(
          stripe_id: stripe_subscription.id
        )
        if subscription.present?
          Fabric.config.logger.info "SubscriptionDeleted: Deleting subscription: "\
            "#{stripe_subscription.id}"
          subscription.destroy
        else
          Fabric.config.logger.info "SubscriptionDeleted: Unable to locate "\
            "subscription: #{stripe_subscription.id}"
        end
      end

    end
  end
end
