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

      saved = Fabric.sync_and_save_subscription_and_items(
        @subscription, stripe_subscription
      )

      Fabric.config.logger.info "UpdateSubscriptionOperation: Completed. "\
        "saved: #{saved}"
    end
  end
end
