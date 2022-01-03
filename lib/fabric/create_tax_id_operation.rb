module Fabric
  class CreateTaxIDOperation
    include Fabric

    def initialize(customer, attributes = {})
      @log_data = {
        class: self.class.name, customer: customer, attributes: attributes
      }
      flogger.json_info 'Started', @log_data

      @customer = get_document(Fabric::Customer, customer) if customer
      @attributes = attributes
    end

    def call
      stripe_tax_id = Stripe::Customer.create_tax_id(
        @customer.stripe_id,
        @attributes
      )

      tax_id = TaxID.new
      tax_id.sync_with stripe_tax_id
      saved = tax_id.save

      flogger.json_info 'Completed', @log_data.merge(saved: saved)

      [tax_id, stripe_tax_id]
    end
  end
end
