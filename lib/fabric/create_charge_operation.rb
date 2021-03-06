module Fabric
  class CreateChargeOperation
    include Fabric

    def initialize(customer, attributes = {})
      Fabric.config.logger.info "CreateChargeOperation: Started with "\
        "#{customer} #{attributes}"
      @customer = get_document(Fabric::Customer, customer)
      @attributes = attributes
    end

    def call
      stripe_charge = Stripe::Charge.create(@attributes)
      charge = @customer.charges.build
      charge.sync_with stripe_charge
      saved = charge.save
      Fabric.config.logger.info "CreateChargeOperation: Completed. "\
        "saved: #{saved}"
      charge
    end
  end
end
