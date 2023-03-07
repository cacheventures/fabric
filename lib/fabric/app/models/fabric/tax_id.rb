module Fabric
  class TaxId
    include Base
    include Mongoid::Document
    include Mongoid::Timestamps

    belongs_to :customer, class_name: 'Fabric::Customer',
      primary_key: :stripe_id

    field :stripe_id, type: String
    field :country, type: String
    field :id_type, type: String
    field :value, type: String
    field :created, type: Time
    field :verification, type: Hash

    validates_uniqueness_of :stripe_id
    validates_presence_of :stripe_id, :id_type, :value

    index({ stripe_id: 1 }, { background: true, unique: true })

    def sync_with(tax_id)
      self.stripe_id = tax_id.id
      self.customer_id = handle_expanded(tax_id.customer)
      self.country = tax_id.country
      self.id_type = tax_id.type
      self.value = tax_id.value
      self.created = tax_id.created
      self.verification = handle_hash(tax_id.verification)
    end
  end
end
