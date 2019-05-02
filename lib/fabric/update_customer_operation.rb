module Fabric
  class UpdateCustomerOperation
    include Fabric

    def initialize(customer, attributes)
      Fabric.config.logger.info "UpdateCustomerOperation: Started with "\
        "#{customer} #{attributes}"
      @customer = get_document(Fabric::Customer, customer)
      @attributes = attributes
    end

    def call
      stripe_customer = Stripe::Customer.retrieve @customer.stripe_id

      @attributes.each { |k, v| stripe_customer.send("#{k}=", v) }
      stripe_customer.save

      @customer.sync_with(stripe_customer)
      saved = @customer.save
      Fabric.config.logger.info "UpdateCustomerOperation: Completed. saved: "\
        "#{saved}"
    end
  end
end
