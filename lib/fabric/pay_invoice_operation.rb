module Fabric
  class PayInvoiceOperation
    include Fabric

    def initialize(invoice, attributes = {})
      @log_data = {
        class: self.class.name, invoice: invoice, attributes: attributes
      }
      flogger.json_info 'Started', @log_data

      @invoice = get_document(Invoice, invoice)
      @attributes = attributes
    end

    def call
      @stripe_invoice = Stripe::Invoice.pay(@invoice.stripe_id, @attributes)

      @invoice.sync_with @stripe_invoice
      saved = @invoice.save

      flogger.json_info 'Completed', @log_data.merge(saved: saved)

      [@invoice, @stripe_invoice]
    rescue Stripe::CardError => error
      raise error unless error.code == 'invoice_payment_intent_requires_action'

      @stripe_invoice = Stripe::Invoice.retrieve(@invoice.stripe_id)
      pi = Stripe::PaymentIntent.retrieve(@stripe_invoice.payment_intent)
      new_error = PaymentIntentError.new(
        error.message,
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
