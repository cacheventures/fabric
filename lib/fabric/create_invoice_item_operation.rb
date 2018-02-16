module Fabric
  class CreateInvoiceItemOperation
    include Fabric

    def initialize(customer, attributes = {})
      Fabric.config.logger.info "CreatedInvoiceItemOperation: Started with "\
        "#{customer} #{attributes}"
      @customer = get_document(Fabric::Customer, customer)
      @attributes = attributes
    end

    def call
      stripe_customer = Stripe::Customer.retrieve(@customer.stripe_id)
      stripe_item = stripe_customer.add_invoice_item(@attributes)
      invoice_item = @customer.invoice_items.build
      invoice_item.sync_with stripe_item
      saved = invoice_item.save
      Fabric.config.logger.info "CreateInvoiceItemOperation: Completed. "\
        "saved: #{saved}"
      invoice_item
    end
  end
end
