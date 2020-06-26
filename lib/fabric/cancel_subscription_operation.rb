module Fabric
  class CancelSubscriptionOperation
    include Fabric

    def initialize(subscription, at_period_end = false)
      Fabric.config.logger.info "CancelSubscriptionOperation: Started with "\
        "#{subscription} #{at_period_end}"
      @subscription = get_document(Fabric::Subscription, subscription)
      @customer = @subscription.customer
      @at_period_end = at_period_end
    end

    def call
      if @at_period_end
        Fabric::UpdateSubscriptionOperation.new(
          @subscription,
          cancel_at_period_end: true
        ).call
      else
        Stripe::Subscription.delete(@subscription.stripe_id)
        @subscription.destroy
      end
    end

  end
end
