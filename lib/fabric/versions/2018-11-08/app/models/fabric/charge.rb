module Fabric
  class Charge
    def sync_with(charge)
      self.stripe_id = Fabric.stripe_id_for charge
      self.amount = charge.amount
      self.amount_refunded = charge.amount_refunded
      self.application = charge.application
      self.application_fee = charge.application_fee
      self.balance_transaction = charge.balance_transaction
      self.captured = charge.captured
      self.created = charge.created
      self.currency = charge.currency
      self.customer = Fabric::Customer.find_by(
        stripe_id: charge.customer
      ) unless customer.present?
      self.description = charge.description
      self.destination = charge.destination
      self.dispute = charge.dispute
      self.failure_code = charge.failure_code
      self.failure_message = charge.failure_message
      self.fraud_details = charge.fraud_details.to_hash
      self.invoice = Fabric::Invoice.find_by(
        stripe_id: charge.invoice
      ) unless invoice.present?
      self.livemode = charge.livemode
      self.metadata = Fabric.convert_metadata(charge.metadata.to_hash)
      self.on_behalf_of = charge.on_behalf_of
      self.order = charge.order
      self.outcome = charge.outcome.to_hash
      self.paid = charge.paid
      self.payment_intent = charge.payment_intent
      self.receipt_email = charge.receipt_email
      self.receipt_number = charge.receipt_number
      self.refunded = charge.refunded
      self.review = charge.review
      self.shipping = charge.shipping.try(:to_hash)
      self.source = charge.source.to_hash if charge.source.present?
      self.source_transfer = charge.source_transfer
      self.statement_descriptor = charge.statement_descriptor
      self.status = charge.status
      self.transfer = charge.try(:transfer)
      self.transfer_group = charge.transfer_group
      self
    end
  end
end
