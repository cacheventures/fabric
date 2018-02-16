module Fabric
  class CreateSubscriptionOperation
    include Fabric

    def initialize(customer, attributes = {})
      Fabric.config.logger.info "CreateSubscriptionOperation: Started with "\
        "#{customer} #{attributes}"
      @customer = get_document(Fabric::Customer, customer)
      @attributes = attributes
    end

    def call
      stripe_customer = Stripe::Customer.retrieve(@customer.stripe_id)

      stripe_subscription = stripe_customer.subscriptions.create @attributes

      subscription = @customer.subscriptions.build
      subscription.sync_with(stripe_subscription)
      saved = subscription.save
      Fabric.config.logger.info "CreateSubscriptionOperation: Completed. "\
        "saved: #{saved}"
      subscription
    end
  end
end
