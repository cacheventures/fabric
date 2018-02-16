module Fabric
  class BillingPolicy
    include Fabric

    def initialize(customer)
      @customer = get_document(Fabric::Customer, customer)
    end

    def billing?
      billing_subscriptions.present?
    end

    def has_subscription?
      @customer.subscriptions.non_canceled.present?
    end

    def billable?
      @customer.sources.present?
    end

    def has_unpaid?
      @customer.subscriptions.unpaid.present?
    end

    # TODO: remove. this logic had to do with another app's plan handling.
    # if not removing this, add a test for this method.
    def plan
      return @plan if @plan.present?

      @paying ||= billing_subscriptions
      @plan = @paying.present? ? @paying.first.plan : Fabric.default_plan
    end

    private

    def billing_subscriptions
      @billing_subscriptions ||= @customer.subscriptions.billing
    end
  end
end
