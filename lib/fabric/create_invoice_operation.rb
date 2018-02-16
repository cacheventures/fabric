module Fabric
  class CreateInvoiceOperation
    include Fabric

    def initialize(customer, attributes = {})
      Fabric.config.logger.info "CreateInvoiceOperation: Started with "\
        "#{customer} #{attributes}"
      @customer = get_document(Fabric::Customer, customer)
      @attributes = attributes
    end

    def call
      stripe_customer = Stripe::Customer.retrieve(@customer.stripe_id)
      stripe_invoice = stripe_customer.invoices.create @attributes
      invoice = @customer.invoices.build
      invoice.sync_with stripe_invoice
      saved = invoice.save
      Fabric.config.logger.info "CreateInvoiceOperation: Completed. "\
        "saved: #{saved}"
      invoice
    end
  end
end
