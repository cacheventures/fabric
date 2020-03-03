module Fabric
  class Dispute
    include Mongoid::Document
    include Mongoid::Timestamps

    belongs_to :charge, class_name: 'Fabric::Charge'
    belongs_to :payment_intent, class_name: 'Fabric::PaymentIntent'

    field :stripe_id, type: String
    field :amount, type: Integer
    field :currency, type: String
    field :evidence, type: Hash
    field :metadata, type: Hash
    field :reason, type: String
    field :status, type: String
    field :object, type: String
    field :balance_transactions, type: Array
    field :created, type: Time
    field :evidence_details, type: Hash
    field :is_charge_refundable, type: Boolean
    field :livemode, type: Boolean

    index({ stripe_id: 1 }, { background: true, unique: true })

    def sync_with(dispute)
      self.stripe_id = dispute.id
      self.amount = dispute.amount
      self.currency = dispute.currency
      self.evidence = dispute.evidence.try(:to_hash)
      self.metadata = dispute.metadata.try(:to_hash)
      self.reason = dispute.reason
      self.status = dispute.status
      self.object = dispute.object
      self.balance_transactions = dispute.balance_transactions.map(&:to_hash)
      self.created = dispute.created
      self.evidence_details = dispute.evidence_details.try(:to_hash)
      self.is_charge_refundable = dispute.is_charge_refundable
      self.livemode = dispute.livemode
      self.charge = Fabric::Charge.find_by(
        stripe_id: dispute.charge
      ) unless charge.present?
      self.payment_intent = Fabric::PaymentIntent.find_by(
        stripe_id: dispute.payment_intent
      ) unless payment_intent.present?
    end
  end
end
