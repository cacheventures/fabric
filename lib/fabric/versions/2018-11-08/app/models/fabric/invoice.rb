module Fabric
  class Invoice
    field :auto_advance, type: Boolean
    field :billing, type: String
    field :billing_reason, type: String
    field :status, type: String

    def sync_with(invoice)
      self.stripe_id = Fabric.stripe_id_for invoice
      self.amount_due = invoice.amount_due
      self.amount_paid = invoice.amount_paid
      self.amount_remaining = invoice.amount_remaining
      self.application_fee = invoice.application_fee
      self.attempt_count = invoice.attempt_count
      self.attempted = invoice.attempted
      self.auto_advance = invoice.auto_advance
      self.billing = invoice.billing
      self.billing_reason = invoice.billing_reason
      self.charge = Fabric::Charge.find_by(
        stripe_id: invoice.charge
      ) unless charge.present?
      self.currency = invoice.currency
      self.date = invoice.date
      self.description = invoice.description
      self.due_date = invoice.due_date
      self.ending_balance = invoice.ending_balance
      self.lines = invoice.lines.to_hash.try(:[], :data)
      self.livemode = invoice.livemode
      self.metadata = Fabric.convert_metadata(invoice.metadata.to_hash)
      self.next_payment_attempt = invoice.next_payment_attempt
      self.number = invoice.number
      self.paid = invoice.paid
      self.period_end = invoice.period_end
      self.period_start = invoice.period_start
      self.receipt_number = invoice.receipt_number
      self.starting_balance = invoice.starting_balance
      self.statement_descriptor = invoice.statement_descriptor
      self.status = invoice.status
      self.subtotal = invoice.subtotal
      self.tax = invoice.tax
      self.tax_percent = invoice.tax_percent
      self.total = invoice.total
      self.webhooks_delivered_at = invoice.webhooks_delivered_at
      self.subscription = invoice.subscription
      self.customer = Fabric::Customer.find_by(
        stripe_id: invoice.customer
      ) unless customer.present?
      self.discount = invoice.discount.try(:to_hash)
      self
    end
  end
end
