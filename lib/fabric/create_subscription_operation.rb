module Fabric
  class CreateSubscriptionOperation
    include Fabric

    def initialize(attributes = {})
      @log_data = { class: self.class.to_s, attributes: attributes }
      Fabric.config.logger.json_info 'started', @log_data
      @attributes = attributes
    end

    def call
      stripe_subscription = Stripe::Subscription.create(@attributes)
      subscription = Fabric::Subscription.new

      subscription.sync_with(stripe_subscription)
      stripe_subscription.items.each do |sub_item|
        item = subscription.subscription_items.build
        item.sync_with(sub_item)
        item.save
      end

      saved = subscription.save

      Fabric.config.logger.json_info 'completed', @log_data.merge(saved: saved)

      [subscription, stripe_subscription]
    end

  end
end
