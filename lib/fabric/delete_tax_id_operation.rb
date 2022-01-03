module Fabric
  class DeleteTaxIdOperation
    include Fabric

    def initialize(customer, tax_id)
      @log_data = {
        class: self.class.name, customer: customer, tax_id: tax_id
      }
      flogger.json_info 'Started', @log_data

      @customer = get_document(Fabric::Customer, customer) if customer
      @tax_id = get_document(Fabric::TaxId, tax_id) if tax_id
    end

    def call
      stripe_delete = Stripe::Customer.delete_tax_id(
        @customer.stripe_id,
        @tax_id.stripe_id
      )
      destroyed = @tax_id.destroy

      flogger.json_info 'Complete', @log_data.merge(
        stripe_delete: stripe_delete, destroyed: destroyed
      )
    end
  end
end
