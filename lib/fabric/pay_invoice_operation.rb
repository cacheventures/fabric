module Fabric
  class PayInvoiceOperation
    include Fabric

    def initialize(invoice)
      Fabric.config.logger.info "PayInvoiceOperation: Started with "\
        "#{invoice}"
      @invoice = get_document(Fabric::Invoice, invoice)
    end

    def call
      stripe_invoice = Stripe::Invoice.retrieve(@invoice.stripe_id)
      unless stripe_invoice.paid
        stripe_invoice.pay
        @invoice.sync_with(stripe_invoice)
        @invoice.save
      end
      Fabric.config.logger.info 'PayInvoiceOperation: Completed.'
    end
  end
end
