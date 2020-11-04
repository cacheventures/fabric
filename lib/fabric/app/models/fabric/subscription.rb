module Fabric
  class Subscription
    include Mongoid::Document
    include Mongoid::Timestamps
    extend Enumerize

    belongs_to :customer, class_name: 'Fabric::Customer', touch: true,
      primary_key: :stripe_id
    has_many :subscription_items, class_name: 'Fabric::SubscriptionItem',
      primary_key: :stripe_id, dependent: :destroy
    belongs_to :default_payment_method, class_name: 'Fabric::PaymentMethod',
      primary_key: :stripe_id

    alias_method :items, :subscription_items

    field :stripe_id, type: String
    field :application_fee_percent, type: Float
    field :cancel_at_period_end, type: Boolean
    field :canceled_at, type: Time
    field :collection_method, type: String
    field :created, type: Time
    field :current_period_end, type: Time
    field :current_period_start, type: Time
    field :start_date, type: Time
    field :status, type: String
    enumerize :status, in: %w[trialing active past_due canceled unpaid incomplete incomplete_expired]
    field :ended_at, type: Time
    field :livemode, type: Boolean
    field :metadata, type: Hash
    field :tax_percent, type: Float
    field :trial_end, type: Time
    field :trial_start, type: Time
    field :discount, type: Hash

    validates_uniqueness_of :stripe_id
    validates :stripe_id, :cancel_at_period_end, :customer_id, :start_date, :status,
              :current_period_end, :current_period_start, presence: true

    scope :active, -> { where(status: 'active') }
    scope :billing, -> { where(:status.in => %w[trialing active past_due]) }
    scope :non_canceled, lambda {
      where(:status.in => %w[trialing active past_due unpaid])
    }
    scope :unpaid, -> { where(:status.in => %w[unpaid past_due]) }

    index({ stripe_id: 1 }, { background: true, unique: true })
    index({ status: 1 }, background: true)

    def sync_with(sub)
      self.stripe_id = Fabric.stripe_id_for sub
      self.application_fee_percent = sub.application_fee_percent
      self.cancel_at_period_end = sub.cancel_at_period_end
      self.canceled_at = sub.canceled_at
      self.collection_method = sub.collection_method
      self.created = sub.created
      self.current_period_end = sub.current_period_end
      self.current_period_start = sub.current_period_start
      self.start_date = sub.start_date
      self.status = sub.status
      self.ended_at = sub.ended_at
      self.livemode = sub.livemode
      self.metadata = Fabric.convert_metadata(sub.metadata.to_hash)
      self.tax_percent = sub.tax_percent
      self.trial_end = sub.trial_end
      self.trial_start = sub.trial_start
      self.customer_id = sub.customer
      self.default_payment_method_id = sub.default_payment_method
      self.discount = sub.discount.try(:to_hash)
      self
    end

    def invoices
      Fabric::Invoice.where(subscription: stripe_id)
    end

  end
end
