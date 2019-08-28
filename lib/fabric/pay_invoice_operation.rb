module Fabric
  class PayInvoiceOperation
    include Fabric

    def initialize(invoice, stripe_invoice: nil)
      Fabric.config.logger.info "PayInvoiceOperation: Started with "\
        "#{invoice} #{stripe_invoice}"

      @invoice = get_document(Fabric::Invoice, invoice)
      @stripe_invoice = stripe_invoice
    end

    def call
      @stripe_invoice ||= Stripe::Invoice.retrieve(@invoice.stripe_id)
      @stripe_invoice.pay unless @stripe_invoice.paid

      @invoice.sync_with @stripe_invoice
      saved = @invoice.save

      Fabric.config.logger.info "PayInvoiceOperation: Completed. "\
        "saved: #{saved}"

      [@invoice, @stripe_invoice]
    rescue Stripe::CardError => error
      raise error unless error.code == 'invoice_payment_intent_requires_action'

      pi = Stripe::PaymentIntent.retrieve(@stripe_invoice.payment_intent)
      new_error = PaymentIntentError.new(
        message,
        code: error.code,
        error: error.error,
        data: {
          payment_intent_client_secret: pi.client_secret
        }
      )
      raise new_error
    end
  end
end
