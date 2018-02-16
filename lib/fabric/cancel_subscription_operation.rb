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
      customer = Stripe::Customer.retrieve(@customer.stripe_id)
      initial_subscription = customer.subscriptions.retrieve(
        @subscription.stripe_id
      )
      stripe_subscription = initial_subscription.delete(
        at_period_end: @at_period_end
      )

      if @at_period_end
        @subscription.sync_with(stripe_subscription)
        @subscription.save
      else
        @subscription.destroy
      end
    end

  end
end
