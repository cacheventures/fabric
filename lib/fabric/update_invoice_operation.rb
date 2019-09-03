module Fabric
  class UpdateInvoiceOperation
    include Fabric

    def initialize(invoice, attributes)
      @log_data = {
        class: self.class.name, invoice: invoice, attributes: attributes
      }
      flogger.json_info 'Started', @log_data

      @invoice = get_document(Invoice, invoice)
      @attributes = attributes
    end

    def call
      stripe_invoice = Stripe::Invoice.update(@invoice.stripe_id, @attributes)

      @invoice.sync_with(stripe_invoice)
      saved = @invoice.save

      flogger.json_info 'Completed', @log_data.merge(saved: saved)

      [@invoice, stripe_invoice]
    end
  end
end
