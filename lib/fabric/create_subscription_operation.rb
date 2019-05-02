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
      stripe_subscription = Stripe::Subscription.create(@attributes)
      subscription = @customer.subscriptions.build
      subscription.sync_with(stripe_subscription)
      stripe_subscription.items.data.each do |sub_item|
        item = subscription.subscription_items.build
        item.sync_with(sub_item)
        item.save
      end
      saved = subscription.save
      Fabric.config.logger.info "CreateSubscriptionOperation: Completed. "\
        "saved: #{saved}"
      subscription
    end
  end
end
