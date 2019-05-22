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

    def billing_subscriptions
      @billing_subscriptions ||= @customer.subscriptions.billing
    end

    def plan
      return @plan if @plan.present?

      @paying ||= billing_subscriptions
      @plan = if @paying.present?
                @paying.first.subscription_items.first.plan
              else
                Fabric.default_plan
              end
    end
  end
end
