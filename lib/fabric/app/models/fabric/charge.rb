module Fabric
  class Charge
    include Mongoid::Document
    include Mongoid::Timestamps

    belongs_to :customer, class_name: 'Fabric::Customer', touch: true

    field :stripe_id, type: String
    field :amount, type: Integer
    field :created, type: Time
    field :currency, type: String
    field :metadata, type: Hash

    def sync_with(charge)
      self.stripe_id = Fabric.stripe_id_for charge
      self.amount = charge.amount
      self.created = charge.created
      self.currency = charge.currency
      self.metadata = charge.metadata.to_hash
    end
  end
end
