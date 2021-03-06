module Fabric
  class InvoiceItem
    include Mongoid::Document
    include Mongoid::Timestamps

    belongs_to :customer, class_name: 'Fabric::Customer', touch: true

    field :stripe_id, type: String
    field :amount, type: Integer
    field :invoice, type: String
    field :currency, type: String

    validates_uniqueness_of :stripe_id

    index({ stripe_id: 1 }, { background: true, unique: true })

    def sync_with(invoice_item)
      self.stripe_id = Fabric.stripe_id_for invoice_item
      self.amount = invoice_item.amount
      self.invoice = invoice_item.invoice
      self.currency = invoice_item.currency
      self.customer = Fabric::Customer.find_by(
        stripe_id: invoice_item.customer
      ) unless customer.present?
    end
  end
end
