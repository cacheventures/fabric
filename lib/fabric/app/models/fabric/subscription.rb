module Fabric
  class Subscription
    include Mongoid::Document
    include Mongoid::Timestamps
    extend Enumerize

    belongs_to :customer, class_name: 'Fabric::Customer', touch: true
    belongs_to :plan, class_name: 'Fabric::Plan'
    has_one :discount, class_name: 'Fabric::Discount', dependent: :destroy

    field :stripe_id, type: String
    field :application_fee_percent, type: Float
    field :cancel_at_period_end, type: Boolean
    field :canceled_at, type: Time
    field :created, type: Time
    field :current_period_end, type: Time
    field :current_period_start, type: Time
    field :quantity, type: Integer, default: 1
    field :start, type: Time
    field :status, type: String
    enumerize :status, in: %w(trialing active past_due canceled unpaid)
    field :ended_at, type: Time
    field :livemode, type: Boolean
    field :metadata, type: Hash
    field :tax_percent, type: Float
    field :trial_end, type: Time
    field :trial_start, type: Time

    validates :stripe_id, :cancel_at_period_end, :customer, :plan, :quantity,
      :start, :status, :current_period_end, :current_period_start,
      presence: true

    scope :active, -> { where(status: 'active') }
    scope :billing, -> { where(:status.in => %w(trialing active past_due)) }
    scope :non_canceled, lambda {
      where(:status.in => %w(trialing active past_due unpaid))
    }
    scope :unpaid, -> { where(:status.in => %w(unpaid past_due)) }

    index({ status: 1 }, background: true)

    def name
      plan.name
    end

    def price
      plan.amount
    end

    def sync_with(sub)
      self.stripe_id = Fabric.stripe_id_for sub
      self.application_fee_percent = sub.application_fee_percent
      self.cancel_at_period_end = sub.cancel_at_period_end
      self.canceled_at = sub.canceled_at
      self.created = sub.created
      self.current_period_end = sub.current_period_end
      self.current_period_start = sub.current_period_start
      self.quantity = sub.quantity
      self.start = sub.start
      self.status = sub.status
      self.ended_at = sub.ended_at
      self.livemode = sub.livemode
      self.metadata = sub.metadata.to_hash
      self.tax_percent = sub.tax_percent
      self.trial_end = sub.trial_end
      self.trial_start = sub.trial_start
      self.plan = Fabric::Plan.find_by(
        stripe_id: Fabric.stripe_id_for(sub.plan)
      )
      self.customer = Fabric::Customer.find_by(
        stripe_id: sub.customer
      ) unless customer.present?
      self
    end

    def invoices
      Fabric::Invoice.where(subscription: stripe_id)
    end

  end
end
