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
    rescue Stripe::CardError => e
      raise e unless e.code == 'invoice_payment_intent_requires_action'

      @stripe_invoice = Stripe::Invoice.retrieve(@invoice.stripe_id)
      @invoice.sync_with @stripe_invoice
      @invoice.save

      stripe_pi = Stripe::PaymentIntent.retrieve(@stripe_invoice.payment_intent)
      pi = PaymentIntent.find_or_initialize_by(stripe_id: stripe_pi.id)
      pi.sync_with stripe_pi
      pi.save

      new_error = PaymentIntentError.new(
        e.message,
        code: e.code,
        error: e.error,
        data: {  payment_intent_client_secret: pi.client_secret }
      )
      raise new_error
    end
  end
end
