module Fabric
  class CreateInvoiceItemOperation
    include Fabric

    def initialize(attributes = {})
      @log_data = { class: self.class.name, attributes: attributes }
      flogger.json_info 'Started', @log_data

      @attributes = attributes
    end

    def call
      stripe_item = Stripe::InvoiceItem.create(@attributes)

      invoice_item = InvoiceItem.new
      invoice_item.sync_with stripe_item
      saved = invoice_item.save

      flogger.json_info 'Completed', @log_data.merge(saved: saved)

      [invoice_item, stripe_item]
    end
  end
end
