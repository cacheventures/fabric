module Fabric
  class Dispute
    include Base
    include Mongoid::Document
    include Mongoid::Timestamps

    belongs_to :charge, class_name: 'Fabric::Charge',
      primary_key: :stripe_id
    belongs_to :payment_intent, class_name: 'Fabric::PaymentIntent',
      primary_key: :stripe_id

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
      self.evidence = handle_hash(dispute.evidence)
      self.metadata = handle_hash(dispute.metadata)
      self.reason = dispute.reason
      self.status = dispute.status
      self.object = dispute.object
      self.balance_transactions = dispute.balance_transactions.map do |e|
        e.to_hash.with_indifferent_access
      end
      self.created = dispute.created
      self.evidence_details = handle_hash(dispute.evidence_details)
      self.is_charge_refundable = dispute.is_charge_refundable
      self.livemode = dispute.livemode
      self.charge_id = handle_expanded(dispute.charge)
      self.payment_intent_id = handle_expanded(dispute.payment_intent)
    end
  end
end
