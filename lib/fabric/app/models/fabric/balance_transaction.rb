module Fabric
  class BalanceTransaction
    include Base
    include Mongoid::Document
    include Mongoid::Timestamps

    has_one :charge, class_name: 'Fabric::Charge', primary_key: :stripe_id,
      inverse_of: 'Fabric::Charge'
    has_one :refund, class_name: 'Fabric::Refund', primary_key: :stripe_id,
      inverse_of: 'Fabric::Refund'

    field :stripe_id, type: String
    field :amount, type: Integer
    field :currency, type: String
    field :description, type: String
    field :fee, type: Integer
    field :fee_details, type: Array
    field :net, type: Integer
    field :source_id, type: String
    field :status, type: String
    field :type, type: String
    field :available_on, type: Time
    field :created, type: Time
    field :exchange_rate, type: Float
    field :reporting_category, type: String

    validates_uniqueness_of :stripe_id
    validates :stripe_id, presence: true

    index({ stripe_id: 1 }, { background: true, unique: true })

    def sync_with(balance_transaction)
      self.stripe_id = stripe_id_for(balance_transaction)
      self.amount = balance_transaction.amount
      self.currency = balance_transaction.currency
      self.description = balance_transaction.description
      self.fee = balance_transaction.try(:fee)
      self.fee_details = balance_transaction.fee_details.map do |e|
        handle_hash(e)
      end
      self.net = balance_transaction.net
      self.source_id = handle_expanded(balance_transaction.source)
      self.status = balance_transaction.status
      self.type = balance_transaction.type
      self.available_on = balance_transaction.available_on
      self.created = balance_transaction.created
      self.exchange_rate = balance_transaction.exchange_rate
      self.reporting_category = balance_transaction.reporting_category
      self
    end

  end
end
