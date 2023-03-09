module Fabric
  class Plan
    include Base
    include Mongoid::Document
    include Mongoid::Timestamps
    extend Enumerize

    belongs_to :product, class_name: 'Fabric::Product',
      primary_key: :stripe_id
    has_many :subscription_items, class_name: 'Fabric::SubscriptionItem',
      primary_key: :stripe_id, inverse_of: :plan

    field :stripe_id, type: String
    field :object, type: String
    field :amount, type: Integer
    field :created, type: Time
    field :currency, type: String
    field :interval, type: String
    enumerize :interval, in: %w(day week month year)
    field :interval_count, type: Integer, default: 1
    field :livemode, type: Boolean
    field :metadata, type: Hash
    field :nickname, type: String
    field :trial_period_days, type: Integer
    field :billing_scheme, type: String
    field :transform_usage, type: Hash
    field :usage_type, type: String

    validates_uniqueness_of :stripe_id
    validates :stripe_id, :amount, :currency, :interval, :created, :product_id,
              presence: true

    index({ stripe_id: 1 }, { background: true, unique: true })

    def sync_with(plan)
      self.stripe_id = plan.id
      self.object = plan.object
      self.amount = plan.amount
      self.created = plan.created
      self.currency = plan.currency
      self.interval = plan.interval
      self.interval_count = plan.interval_count
      self.livemode = plan.livemode
      self.metadata = convert_metadata(plan.metadata)
      self.nickname = plan.nickname
      self.trial_period_days = plan.trial_period_days
      self.product_id = plan.product
      self.billing_scheme = plan.billing_scheme
      if plan.transform_usage.present?
        self.transform_usage = handle_hash(plan.transform_usage)
      end
      self.usage_type = plan.usage_type
      self
    end
  end
end
