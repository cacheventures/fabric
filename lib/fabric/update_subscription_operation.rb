module Fabric
  class UpdateSubscriptionOperation
    include Fabric

    def initialize(subscription, attributes)
      Fabric.config.logger.info "UpdateSubscriptionOperation: Started with "\
        "#{subscription} #{attributes}"
      @subscription = get_document(Fabric::Subscription, subscription)
      @customer = @subscription.customer
      @attributes = attributes
    end

    def call
      stripe_customer = Stripe::Customer.retrieve @customer.stripe_id
      stripe_subscription = stripe_customer.subscriptions.retrieve(
        @subscription.stripe_id
      )

      @attributes.each { |k, v| stripe_subscription.send("#{k}=", v) }
      stripe_subscription.save

      @subscription.sync_with(stripe_subscription)
      stripe_subscription.items.data.each do |sub_item|
        item = @subscription.subscription_items.find_by(
          stripe_id: sub_item.id
        )
        item.sync_with(sub_item)
        item.save
      end
      saved = @subscription.save
      Fabric.config.logger.info "UpdateSubscriptionOperation: Completed. "\
        "saved: #{saved}"
    end
  end
end
