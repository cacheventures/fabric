module Fabric
  class InvoiceItem
    include Base
    include Mongoid::Document
    include Mongoid::Timestamps

    belongs_to :customer, class_name: 'Fabric::Customer',
      primary_key: :stripe_id, touch: true
    belongs_to :invoice, class_name: 'Fabric::Invoice', primary_key: :stripe_id
    belongs_to :subscription, class_name: 'Fabric::Subscription',
      primary_key: :stripe_id

    field :stripe_id, type: String
    field :amount, type: Integer
    field :currency, type: String
    field :date, type: Time
    field :description, type: String
    field :discountable, type: Boolean
    field :discounts, type: Array
    field :livemode, type: Boolean
    field :metadata, type: Hash
    field :period, type: Hash
    field :price, type: Hash
    field :proration, type: Boolean
    field :quantity, type: Integer
    field :subscription_item, type: String
    field :tax_rates, type: Array
    field :unit_amount, type: Integer
    field :unit_amount_decimal, type: String

    validates :stripe_id, presence: true, uniqueness: true

    index({ stripe_id: 1 }, { background: true, unique: true })

    def sync_with(invoice_item)
      self.stripe_id = invoice_item.id
      self.amount = invoice_item.amount
      self.currency = invoice_item.currency
      self.customer_id = handle_expanded(invoice_item.customer)
      self.date = invoice_item.date
      self.description = invoice_item.description
      self.discountable = invoice_item.discountable
      self.discounts = invoice_item.discounts
      self.invoice_id = handle_expanded(invoice_item.invoice)
      self.livemode = invoice_item.livemode
      self.metadata = convert_metadata(invoice_item.metadata)
      self.period = handle_hash(invoice_item.period)
      self.price = handle_hash(invoice_item.price)
      self.proration = invoice_item.proration
      self.quantity = invoice_item.quantity
      self.subscription_id = handle_expanded(invoice_item.subscription)
      self.tax_rates = invoice_item.tax_rates.map do |tr|
        handle_hash(tr)
      end
      self.unit_amount = invoice_item.unit_amount
      self.unit_amount_decimal = invoice_item.unit_amount_decimal
    end
  end
end
