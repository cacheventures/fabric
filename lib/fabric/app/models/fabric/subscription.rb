module Fabric
  class Subscription
    include Base
    include Mongoid::Document
    include Mongoid::Timestamps
    extend Enumerize

    belongs_to :customer, class_name: 'Fabric::Customer', touch: true,
      primary_key: :stripe_id
    belongs_to :default_payment_method, class_name: 'Fabric::PaymentMethod',
      primary_key: :stripe_id
    belongs_to :latest_invoice, class_name: 'Fabric::Invoice',
      primary_key: :stripe_id, foreign_key: :latest_invoice_id, inverse_of: nil
    belongs_to :pending_setup_intent, class_name: 'Fabric::SetupIntent',
      primary_key: :stripe_id, foreign_key: :pending_setup_intent_id,
      inverse_of: nil
    has_many :subscription_items, class_name: 'Fabric::SubscriptionItem',
      primary_key: :stripe_id, dependent: :destroy

    alias_method :items, :subscription_items

    field :stripe_id, type: String
    field :application_fee_percent, type: Float
    field :automatic_tax, type: Hash
    field :billing_cycle_anchor, type: Time
    field :billing_thresholds, type: Hash
    field :cancel_at, type: Time
    field :cancel_at_period_end, type: Boolean
    field :canceled_at, type: Time
    field :cancellation_details, type: Hash
    field :collection_method, type: String
    field :created, type: Time
    field :currency, type: String
    field :current_period_end, type: Time
    field :current_period_start, type: Time
    field :days_until_due, type: Integer
    field :default_tax_rates, type: Array
    field :description, type: String
    field :discount, type: Hash
    field :ended_at, type: Time
    field :livemode, type: Boolean
    field :metadata, type: Hash
    field :next_pending_invoice_item_invoice, type: Time
    field :pause_collection, type: Hash
    field :payment_settings, type: Hash
    field :pending_invoice_item_interval, type: Hash
    field :pending_update, type: Hash
    field :start_date, type: Time
    field :status, type: String
    enumerize :status, in: %w[
      active canceled incomplete incomplete_expired past_due paused trialing
      unpaid
    ]
    field :tax_percent, type: Float
    field :trial_end, type: Time
    field :trial_settings, type: Hash
    field :trial_start, type: Time

    validates_uniqueness_of :stripe_id
    validates_presence_of :stripe_id, :customer_id, :status

    scope :active, -> { where(status: 'active') }
    scope :billing, -> { where(:status.in => %w[active past_due trialing]) }
    scope :non_canceled, lambda {
      where(:status.in => %w[active past_due paused trialing unpaid])
    }
    scope :unpaid, -> { where(:status.in => %w[past_due unpaid]) }

    index({ stripe_id: 1 }, { background: true, unique: true })
    index({ status: 1 }, background: true)

    def sync_with(sub)
      self.stripe_id = sub.id
      self.application_fee_percent = sub.application_fee_percent
      self.automatic_tax = handle_hash(sub.automatic_tax)
      self.billing_cycle_anchor = sub.billing_cycle_anchor
      self.billing_thresholds = handle_hash(sub.billing_thresholds)
      self.cancel_at = sub.cancel_at
      self.cancel_at_period_end = sub.cancel_at_period_end
      self.canceled_at = sub.canceled_at
      self.cancellation_details = handle_hash(sub.cancellation_details)
      self.collection_method = sub.collection_method
      self.created = sub.created
      self.currency = sub.currency
      self.current_period_end = sub.current_period_end
      self.current_period_start = sub.current_period_start
      self.customer_id = handle_expanded(sub.customer)
      self.days_until_due = sub.days_until_due
      self.default_payment_method_id = handle_expanded(sub.default_payment_method)
      self.default_tax_rates = sub.default_tax_rates.map do |dtr_hash|
        handle_hash(dtr_hash)
      end
      self.description = sub.description
      self.discount = handle_hash(sub.discount)
      self.ended_at = sub.ended_at
      self.latest_invoice_id = handle_expanded(sub.latest_invoice)
      self.livemode = sub.livemode
      self.metadata = convert_metadata(sub.metadata)
      self.next_pending_invoice_item_invoice = sub.next_pending_invoice_item_invoice
      self.pause_collection = handle_hash(sub.pause_collection)
      self.payment_settings = handle_hash(sub.payment_settings)
      self.pending_invoice_item_interval = handle_hash(sub.pending_invoice_item_interval)
      self.pending_setup_intent_id = handle_expanded(sub.pending_setup_intent)
      self.pending_update = handle_hash(sub.pending_update)
      self.start_date = sub.start_date
      self.status = sub.status
      self.tax_percent = sub.tax_percent
      self.trial_end = sub.trial_end
      self.trial_settings = handle_hash(sub.trial_settings)
      self.trial_start = sub.trial_start
      self
    end

    def invoices
      Fabric::Invoice.where(subscription_id: stripe_id)
    end

  end
end
