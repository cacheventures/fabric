module Fabric
  class InvoiceItem
    include Base
    include Mongoid::Document
    include Mongoid::Timestamps

    belongs_to :customer, class_name: 'Fabric::Customer',
      primary_key: :stripe_id, touch: true

    field :stripe_id, type: String
    field :amount, type: Integer
    field :invoice, type: String
    field :currency, type: String

    validates_uniqueness_of :stripe_id

    index({ stripe_id: 1 }, { background: true, unique: true })

    def sync_with(invoice_item)
      self.stripe_id = invoice_item.id
      self.amount = invoice_item.amount
      self.invoice = invoice_item.invoice
      self.currency = invoice_item.currency
      self.customer_id = handle_expanded(invoice_item.customer)
    end
  end
end
