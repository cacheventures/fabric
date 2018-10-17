module Fabric
  class UpdateSubscriptionOperation
    include Fabric

    def initialize(subscription, attributes)
      Fabric.config.logger.info "UpdateSubscriptionOperation: Started with "\
        "#{subscription} #{attributes}"
      @subscription = get_document(Fabric::Subscription, subscription)
      @attributes = attributes
    end

    def call
      stripe_subscription = Stripe::Subscription.retrieve(
        @subscription.stripe_id
      )

      @attributes.each { |k, v| stripe_subscription.send("#{k}=", v) }
      stripe_subscription.save

      @subscription.sync_with(stripe_subscription)
      sub_items = @subscription.subscription_items
      stripe_subscription.items.data.each do |sub_item|
        item = sub_items.find_by(stripe_id: sub_item.id) || sub_items.build
        item.sync_with(sub_item)
        item.save
      end
      saved = @subscription.save
      Fabric.config.logger.info "UpdateSubscriptionOperation: Completed. "\
        "saved: #{saved}"
    end
  end
end
