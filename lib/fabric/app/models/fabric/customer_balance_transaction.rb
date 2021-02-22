module Fabric
  class CustomerBalanceTransaction
    include Mongoid::Document
    include Mongoid::Timestamps

    belongs_to :customer, class_name: 'Fabric::Customer',
      primary_key: :stripe_id
    belongs_to :invoice, class_name: 'Fabric::Invoice',
      primary_key: :stripe_id

    field :stripe_id, type: String
    field :amount, type: Integer
    field :currency, type: String
    field :description, type: String
    field :ending_balance, type: Integer
    field :metadata, type: Hash
    field :type, type: String
    field :created, type: Time

    validates_uniqueness_of :stripe_id
    validates :customer_id, :stripe_id, presence: true

    def sync_with(customer_balance_transaction)
      self.stripe_id = Fabric.stripe_id_for customer_balance_transaction
      self.customer_id = customer_balance_transaction.customer
      self.invoice_id = customer_balance_transaction.invoice
      self.amount = customer_balance_transaction.amount
      self.currency = customer_balance_transaction.currency
      self.description = customer_balance_transaction.description
      self.ending_balance = customer_balance_transaction.ending_balance
      self.metadata = Fabric.convert_metadata(customer_balance_transaction.metadata.to_hash)
      self.type = customer_balance_transaction.type
      self.created = customer_balance_transaction.created
    end
  end
end
