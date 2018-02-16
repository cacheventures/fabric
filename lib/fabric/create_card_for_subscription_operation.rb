module Fabric
  class CreateCardForSubscriptionOperation
    include Fabric

    def initialize(customer, token_or_card, attributes = {})
      Fabric.config.logger.info "CreateCardForSubscriptionOperation: Started "\
        "with #{customer} #{token_or_card} #{attributes}"
      @customer = get_document(Fabric::Customer, customer)
      @card = token_or_card
      @billing_policy = Fabric::BillingPolicy.new(@customer)
      @attributes = attributes
    end

    def call
      Fabric::CreateCardOperation.new(@customer, @card).call

      Fabric::CreateSubscriptionOperation.new(
        @customer,
        @attributes
      ).call
      Fabric.config.logger.info "CreateCardForSubscriptionOperation: "\
      "Completed."
    end
  end
end
