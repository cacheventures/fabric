module Fabric
  class PayInvoiceOperation

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
