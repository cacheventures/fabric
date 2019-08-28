module Fabric
  class Charge
    include Mongoid::Document
    include Mongoid::Timestamps
    extend Enumerize

    belongs_to :customer, class_name: 'Fabric::Customer', touch: true
    belongs_to :invoice, class_name: 'Fabric::Invoice'
    belongs_to :payment_intent, class_name: 'Fabric::PaymentIntent'

    field :stripe_id, type: String
    field :amount, type: Integer
    field :amount_refunded, type: Integer
    field :application, type: String
    field :application_fee, type: String
    field :balance_transaction, type: String
    field :captured, type: Boolean
    field :created, type: Time
    field :currency, type: String
    field :description, type: String
    field :destination, type: String
    field :dispute, type: String
    field :failure_code, type: String
    field :failure_message, type: String
    field :fraud_details, type: Hash
    field :livemode, type: Boolean
    field :metadata, type: Hash
    field :on_behalf_of, type: String
    field :order, type: String
    field :outcome, type: Hash
    field :paid, type: Boolean
    field :receipt_email, type: String
    field :receipt_number, type: String
    field :refunded, type: Boolean
    field :review, type: String
    field :shipping, type: Hash
    field :source, type: Hash
    field :source_transfer, type: String
    field :statement_descriptor, type: String
    field :status, type: String
    enumerize :status, in: %w[succeeded pending failed]
    field :transfer, type: String
    field :transfer_group, type: String

    scope :succeeded, -> { where(status: 'succeeded') }
    scope :pending, -> { where(status: 'pending') }
    scope :failed, -> { where(status: 'failed') }

    validates_uniqueness_of :stripe_id
    validates :stripe_id, presence: true

    index({ stripe_id: 1 }, { background: true, unique: true })

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
      self.payment_intent = Fabric::PaymentIntent.find_by(
        stripe_id: charge.payment_intent
      ) unless payment_intent.present?
      self.receipt_email = charge.receipt_email
      self.receipt_number = charge.receipt_number
      self.refunded = charge.refunded
      self.review = charge.review
      self.shipping = charge.shipping.try(:to_hash)
      self.source = charge.source.to_hash
      self.source_transfer = charge.source_transfer
      self.statement_descriptor = charge.statement_descriptor
      self.status = charge.status
      self.transfer = charge.try(:transfer)
      self.transfer_group = charge.transfer_group
      self
    end
  end
end
