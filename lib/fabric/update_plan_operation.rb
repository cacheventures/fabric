module Fabric
  class UpdatePlanOperation
    include Fabric

    def initialize(customer, plan_id)
      Fabric.config.logger.info "UpdatePlanOperation: Started with "\
        "#{customer} #{plan_id}"
      @customer = get_document(Fabric::Customer, customer)
      @plan_id = plan_id
    end

    def call
      subscriptions = @customer.subscriptions.non_canceled.to_a
      if subscriptions.present?
        subscriptions.each do |subscription|
          UpdateSubscriptionOperation.new(
            subscription,
            plan: @plan_id
          ).call
        end
      end
    end

  end
end
