module Fabric
  class UpdateInvoiceOperation
    include Fabric

    def initialize(invoice, attributes)
      Fabric.config.logger.info "UpdateInvoiceOperation: Started with "\
        "#{invoice} #{attributes}"
      @invoice = get_document(Fabric::Invoice, invoice)
      @attributes = attributes
    end

    def call
      stripe_invoice = Stripe::Invoice.retrieve(@invoice.stripe_id)

      @attributes.each { |k,v| stripe_invoice.send("#{k}=", v) }
      stripe_invoice.save

      @invoice.sync_with(stripe_invoice)
      saved = @invoice.save
      Fabric.config.logger.info "UpdateInvoiceOperation: Completed. saved: #{saved}"
    end
  end
end
