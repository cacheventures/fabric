module Fabric
  class CreateInvoiceOperation
    include Fabric

    def initialize(attributes = {})
      @log_data = { class: self.class.name, attributes: attributes }
      flogger.json_info 'Started', @log_data

      @attributes = attributes
    end

    def call
      stripe_invoice = Stripe::Invoice.create(@attributes)

      invoice = Invoice.new
      invoice.sync_with stripe_invoice
      saved = invoice.save

      flogger.json_info 'Completed', @log_data.merge(saved: saved)

      [invoice, stripe_invoice]
    end
  end
end
