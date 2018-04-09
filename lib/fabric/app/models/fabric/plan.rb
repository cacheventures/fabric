module Fabric
  class Plan
    include Mongoid::Document
    include Mongoid::Timestamps
    extend Enumerize

    has_many :subscription_items, class_name: 'Fabric::SubscriptionItem',
                                  inverse_of: :plan

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
    field :product, type: String

    validates :stripe_id, :amount, :currency, :interval, :created, :product,
      presence: true

    def sync_with(plan)
      self.stripe_id = Fabric.stripe_id_for plan
      self.object = plan.object
      self.amount = plan.amount
      self.created = plan.created
      self.currency = plan.currency
      self.interval = plan.interval
      self.interval_count = plan.interval_count
      self.livemode = plan.livemode
      self.metadata = plan.metadata.to_hash
      self.name = plan.name
      self.trial_period_days = plan.trial_period_days
      self.product = plan.product
      self
    end
  end
end
