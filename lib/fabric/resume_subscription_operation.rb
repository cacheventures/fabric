module Fabric
  class ResumeSubscriptionOperation
    include Fabric

    def initialize(subscription)
      Fabric.config.logger.info "ResumeSubscriptionOperation: Started with "\
        "#{subscription}"
      @subscription = get_document(Fabric::Subscription, subscription)
      @customer = @subscription.customer
    end

    def call
      Fabric::UpdateSubscriptionOperation.new(
        @subscription,
        { plan: @subscription.plan.stripe_id }
      ).call
    end
  end
end
