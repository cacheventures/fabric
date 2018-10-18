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
      stripe_invoice.pay unless stripe_invoice.paid
      Fabric.config.logger.info 'PayInvoiceOperation: Completed.'
    end
  end
end
