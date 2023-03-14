module Fabric
  class CancelSubscriptionOperation
    include Fabric

    def initialize(subscription, attributes)
      Fabric.config.logger.info "CancelSubscriptionOperation: Started with "\
        "#{subscription} #{attributes}"
      @subscription = get_document(Fabric::Subscription, subscription)
      @attributes = attributes
    end

    def call
      stripe_subscription = Stripe::Subscription.cancel(
        @subscription.stripe_id, attributes
      )

      @subscription.sync_with(stripe_subscription)
      @subscription.save

      [@subscription, stripe_subscription]
    end

  end
end
