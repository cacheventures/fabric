module Fabric
  class Charge
    include Mongoid::Document
    include Mongoid::Timestamps
    extend Enumerize

    belongs_to :customer, class_name: 'Fabric::Customer',
      primary_key: :stripe_id, touch: true
    belongs_to :invoice, class_name: 'Fabric::Invoice',
      primary_key: :stripe_id
    belongs_to :payment_intent, class_name: 'Fabric::PaymentIntent',
      primary_key: :stripe_id
    belongs_to :balance_transaction, class_name: 'Fabric::BalanceTransaction',
      primary_key: :stripe_id
    has_many :refunds, class_name: 'Fabric::Refund', primary_key: :stripe_id
    has_one :review, class_name: 'Fabric::Review', primary_key: :stripe_id

    field :stripe_id, type: String
    field :amount, type: Integer
    field :amount_refunded, type: Integer
    field :application, type: String
    field :application_fee, type: String
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
    field :receipt_url, type: String
    field :refunded, type: Boolean
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
      self.balance_transaction_id = charge.balance_transaction
      self.captured = charge.captured
      self.created = charge.created
      self.currency = charge.currency
      self.customer_id = charge.customer
      self.description = charge.description
      self.destination = charge.destination
      self.dispute = charge.dispute
      self.failure_code = charge.failure_code
      self.failure_message = charge.failure_message
      self.fraud_details = charge.fraud_details&.to_hash&.with_indifferent_access
      self.invoice_id = charge.invoice
      self.livemode = charge.livemode
      self.metadata = Fabric.convert_metadata(charge.metadata)
      self.on_behalf_of = charge.on_behalf_of
      self.order = charge.order
      self.outcome = charge.outcome&.to_hash&.with_indifferent_access
      self.paid = charge.paid
      self.payment_intent_id = charge.payment_intent
      self.receipt_email = charge.receipt_email
      self.receipt_number = charge.receipt_number
      self.receipt_url = charge.receipt_url
      self.refunded = charge.refunded
      self.shipping = charge.shipping&.to_hash&.with_indifferent_access
      self.source = charge.source&.to_hash&.with_indifferent_access
      self.source_transfer = charge.source_transfer
      self.statement_descriptor = charge.statement_descriptor
      self.status = charge.status
      self.transfer = charge.try(:transfer)
      self.transfer_group = charge.transfer_group
      sync_external(charge)
      self
    end

    def sync_external(charge)
      if charge.balance_transaction
        sbt = Stripe::BalanceTransaction.retrieve(charge.balance_transaction)
        fbt = Fabric::BalanceTransaction.find_or_initialize_by(stripe_id: sbt.id)
        fbt.sync_with(sbt).save
      end

      refunds = charge.refunds.data
      if refunds.size.positive? && self.refunds.size != refunds.size
        refunds.each do |sr|
          fr = Fabric::Refund.find_or_initialize_by(stripe_id: sr.id)
          fr.sync_with(sr).save
        end
      end
    end
  end
end
