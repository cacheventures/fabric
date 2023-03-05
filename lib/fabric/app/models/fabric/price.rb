module Fabric
  class Price
    include Base
    include Mongoid::Document
    include Mongoid::Timestamps

    belongs_to :product, class_name: 'Fabric::Product',
      primary_key: :stripe_id
    has_many :subscription_items, class_name: 'Fabric::SubscriptionItem',
      primary_key: :stripe_id, inverse_of: :price

    field :stripe_id, type: String
    field :active, type: Boolean
    field :billing_scheme, type: String
    field :created, type: Time
    field :currency_options, type: Hash # excluded; not expanded by default
    field :currency, type: String
    field :custom_unit_amount, type: Hash
    field :livemode, type: Boolean
    field :lookup_key, type: String
    field :metadata, type: Hash
    field :nickname, type: String
    field :recurring, type: Hash
    field :tax_behavior, type: String
    field :tiers_mode, type: String
    field :tiers, type: Array # excluded; not expanded by default
    field :transform_quantity, type: Hash
    field :type, type: String
    field :unit_amount_decimal, type: String # decimal string
    field :unit_amount, type: Integer

    validates_uniqueness_of :stripe_id
    validates :stripe_id, :currency, presence: true

    index({ stripe_id: 1 }, { background: true, unique: true })

    def sync_with(price)
      self.stripe_id = stripe_id_for(price)
      self.active = price.active
      self.billing_scheme = price.billing_scheme
      self.created = price.created
      self.currency = price.currency
      self.currency_options = handle_hash(price.currency_options)
      self.custom_unit_amount = handle_hash(price.custom_unit_amount)
      self.livemode = price.livemode
      self.lookup_key = price.lookup_key
      self.metadata = convert_metadata(price.metadata)
      self.nickname = price.nickname
      self.product_id = price.product
      self.recurring = handle_hash(price.recurring)
      self.tax_behavior = price.tax_behavior
      self.tiers = price.try(:tiers)&.map { |tier| handle_hash(tier) }
      self.tiers_mode = price.tiers_mode
      self.transform_quantity = handle_hash(price.transform_quantity)
      self.type = price.type
      self.unit_amount = price.unit_amount
      self.unit_amount_decimal = price.unit_amount_decimal
      self
    end

    # Stripe has multiple currency support for Prices. To make sure we expand
    # all of the tiers, we check the configured currencies for Fabric and expand
    # every currency's tiers.
    def expand_attributes
      return %w(tiers) if Fabric.config.currencies.count == 1

      %w(tiers currency_options) + Fabric.config.currencies.map do |currency|
        "currency_options.#{currency}.tiers"
      end
    end

  end
end
