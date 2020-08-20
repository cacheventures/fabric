module Fabric
  class DeleteSubscriptionOperation
    include Fabric

    def initialize(subscription, attributes = {})
      @log_data = {
        class: self.class.name, subscription: subscription,
        attributes: attributes
      }
      flogger.json_info 'Started', @log_data

      @subscription = get_document(Fabric::Subscription, subscription)
      @attributes = attributes
    end

    def call
      stripe_delete = Stripe::Subscription.delete(
        @subscription.stripe_id, @attributes
      )
      destroyed = @subscription.destroy

      flogger.json_info 'Complete', @log_data.merge(
        stripe_delete: stripe_delete, destroyed: destroyed
      )
    end
  end
end
