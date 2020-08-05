module Fabric
  class Price
    include Mongoid::Document
    include Mongoid::Timestamps
    extend Enumerize

    belongs_to :product, class_name: 'Fabric::Product'
    has_many :subscription_items, class_name: 'Fabric::SubscriptionItem',
      inverse_of: :price

    field :stripe_id, type: String
    field :active, type: Boolean
    field :billing_scheme, type: String
    field :created, type: Time
    field :currency, type: String
    field :livemode, type: Boolean
    field :lookup_key, type: String
    field :metadata, type: Hash
    field :nickname, type: String
    field :recurring, type: Hash
    field :tiers, type: Array # excluded; not expanded by default
    field :tiers_mode, type: String
    field :transform_quantity, type: Hash
    field :type, type: String
    field :unit_amount, type: Integer
    field :unit_amount_decimal, type: String # decimal string

    validates_uniqueness_of :stripe_id
    validates :stripe_id, :currency, presence: true

    index({ stripe_id: 1 }, { background: true, unique: true })

    def sync_with(price)
      self.stripe_id = Fabric.stripe_id_for price
      self.active = price.active
      self.billing_scheme = price.billing_scheme
      self.created = price.created
      self.currency = price.currency
      self.livemode = price.livemode
      self.lookup_key = price.lookup_key
      self.metadata = Fabric.convert_metadata(price.metadata.to_hash)
      self.nickname = price.nickname
      self.product = Fabric::Product.find_by(
        stripe_id: price.product
      ) unless product.present?
      self.recurring = price.recurring.try(:to_hash)
      self.tiers = price.try(:tiers)&.map { |tier| tier.to_hash }
      self.tiers_mode = price.tiers_mode
      self.transform_quantity = price.transform_quantity.try(:to_hash)
      self.type = price.type
      self.unit_amount = price.unit_amount
      self.unit_amount_decimal = price.unit_amount_decimal
      self
    end

  end
end
