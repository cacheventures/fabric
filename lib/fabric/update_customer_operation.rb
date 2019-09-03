module Fabric
  class UpdateCustomerOperation
    include Fabric

    def initialize(customer, attributes)
      @log_data = {
        class: self.class.name, customer: customer, attributes: attributes
      }
      flogger.json_info 'Started', @log_data
      @customer = get_document(Fabric::Customer, customer)
      @attributes = attributes
    end

    def call
      stripe_customer = Stripe::Customer.update(
        @customer.stripe_id, @attributes
      )
      @customer.sync_with(stripe_customer)
      saved = @customer.save

      flogger.json_info 'Completed', @log_data.merge(saved: saved)

      [@customer, stripe_customer]
    end
  end
end
