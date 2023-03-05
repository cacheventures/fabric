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
      @customer.payment_methods.present?
    end

    def has_unpaid?
      @customer.subscriptions.unpaid.present?
    end

    def billing_subscriptions
      @billing_subscriptions ||= @customer.subscriptions.billing
    end
  end
end
