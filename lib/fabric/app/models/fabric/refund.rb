module Fabric
  class Refund
    include Mongoid::Document
    include Mongoid::Timestamps

    belongs_to :charge, class_name: 'Fabric::Charge',
      primary_key: :stripe_id
    belongs_to :payment_intent, class_name: 'Fabric::PaymentIntent',
      primary_key: :stripe_id
    belongs_to :balance_transaction, class_name: 'Fabric::BalanceTransaction',
      primary_key: :stripe_id
    belongs_to :failure_balance_transaction,
      class_name: 'Fabric::BalanceTransaction',
      primary_key: :stripe_id

    field :stripe_id, type: String
    field :charge_id, type: String
    field :payment_intent_id, type: String
    field :amount, type: Integer
    field :currency, type: String
    field :description, type: String
    field :metadata, type: Hash
    field :reason, type: String
    field :status, type: String
    field :created, type: Time
    field :failure_reason, type: String
    field :receipt_number, type: String
    field :source_transfer_reversal, type: String
    field :transfer_reversal, type: String

    validates_uniqueness_of :stripe_id
    validates :stripe_id, presence: true

    index({ stripe_id: 1 }, { background: true, unique: true })

    def sync_with(refund)
      self.stripe_id = Fabric.stripe_id_for refund
      self.charge_id = refund.charge
      self.payment_intent_id = refund.payment_intent
      self.amount = refund.amount
      self.balance_transaction_id = refund.balance_transaction
      self.currency = refund.currency
      self.description = refund.try(:description)
      self.metadata = Fabric.convert_metadata(refund.metadata)
      self.reason = refund.reason
      self.status = refund.status
      self.created = refund.created
      self.failure_balance_transaction_id = refund.try(:failure_balance_transaction)
      self.failure_reason = refund.try(:failure_reason)
      self.receipt_number = refund.receipt_number
      self.source_transfer_reversal = refund.source_transfer_reversal
      self.transfer_reversal = refund.transfer_reversal
      sync_external(refund)
      self
    end

    def sync_external(refund)
      if refund.balance_transaction
        sbt = Stripe::BalanceTransaction.retrieve(refund.balance_transaction)
        fbt = Fabric::BalanceTransaction.find_or_initialize_by(stripe_id: sbt.id)
        fbt.sync_with(sbt).save
      end
      if refund.try(:failure_balance_transaction)
        sbt = Stripe::BalanceTransaction.retrieve(refund.failure_balance_transaction)
        fbt = Fabric::BalanceTransaction.find_or_initialize_by(stripe_id: sbt.id)
        fbt.sync_with(sbt).save
      end
    end

  end
end
