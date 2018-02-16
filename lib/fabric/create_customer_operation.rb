module Fabric
  class CreateCustomerOperation
    include Fabric

    def initialize(attributes = {})
      Fabric.config.logger.info "CreateCustomerOperation: Started with "\
        "#{attributes}"
      @attributes = attributes
    end

    def call
      stripe_customer = Stripe::Customer.create @attributes

      customer = Fabric::Customer.new
      customer.sync_with(stripe_customer)

      saved = customer.save
      Fabric.config.logger.info "CreateCustomerOperation: Completed. saved: "\
        "#{saved}"
      customer
    end
  end
end
