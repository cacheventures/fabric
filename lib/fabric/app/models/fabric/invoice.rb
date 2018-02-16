module Fabric
  class Invoice
    include Mongoid::Document
    include Mongoid::Timestamps

    belongs_to :customer, class_name: 'Fabric::Customer'

    field :stripe_id, type: String
    field :amount_due, type: Integer
    field :application_fee, type: Integer
    field :attempt_count, type: Integer
    field :attempted, type: Boolean
    field :charge, type: String
    field :closed, type: Boolean
    field :currency, type: String
    field :date, type: Time
    field :description, type: String
    field :discount, type: Hash
    field :ending_balance, type: Integer
    field :forgiven, type: Boolean
    field :lines, type: Array
    field :livemode, type: Boolean
    field :metadata, type: Hash
    field :next_payment_attempt, type: Time
    field :paid, type: Boolean
    field :period_end, type: Time
    field :period_start, type: Time
    field :receipt_number, type: String
    field :starting_balance, type: Integer
    field :statement_descriptor, type: String
    # we can't associate subscriptions because invoices come first
    field :subscription, type: String
    field :subtotal, type: Integer
    field :tax, type: Integer
    field :tax_percent, type: Float
    field :total, type: Integer
    field :webhooks_delivered_at, type: Time

    validates :customer_id, :stripe_id, presence: true

    index({ customer_id: 1, subscription: 1 }, background: true)
    index({ stripe_id: 1 }, background: true)

    def sync_with(invoice)
      self.stripe_id = Fabric.stripe_id_for invoice
      self.amount_due = invoice.amount_due
      self.application_fee = invoice.application_fee
      self.attempt_count = invoice.attempt_count
      self.attempted = invoice.attempted
      self.charge = invoice.charge
      self.closed = invoice.closed
      self.currency = invoice.currency
      self.date = invoice.date
      self.description = invoice.description
      self.discount = invoice.try(:discount).try(:to_hash) # could be nil
      self.ending_balance = invoice.ending_balance
      self.forgiven = invoice.forgiven
      self.lines = invoice.lines.to_hash.try(:[], :data)
      self.livemode = invoice.livemode
      self.metadata = invoice.metadata.to_hash
      self.next_payment_attempt = invoice.next_payment_attempt
      self.paid = invoice.paid
      self.period_end = invoice.period_end
      self.period_start = invoice.period_start
      self.receipt_number = invoice.receipt_number
      self.starting_balance = invoice.starting_balance
      self.statement_descriptor = invoice.statement_descriptor
      self.subtotal = invoice.subtotal
      self.tax = invoice.tax
      self.tax_percent = invoice.tax_percent
      self.total = invoice.total
      self.webhooks_delivered_at = invoice.webhooks_delivered_at
      self.subscription = invoice.subscription
      self.customer = Fabric::Customer.find_by(
        stripe_id: invoice.customer
      ) unless customer.present?
      self
    end

  end
end
