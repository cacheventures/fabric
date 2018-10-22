module Fabric
  class Customer
    include Mongoid::Document
    include Mongoid::Timestamps
    extend Enumerize

    has_many :subscriptions, class_name: 'Fabric::Subscription',
      dependent: :destroy
    has_many :sources, class_name: 'Fabric::Card', dependent: :destroy
    has_many :invoices, class_name: 'Fabric::Invoice', dependent: :destroy
    has_many :events, class_name: 'Fabric::Event', inverse_of: :customer,
      dependent: :destroy
    has_many :discounts, class_name: 'Fabric::Discount', dependent: :destroy
    has_many :charges, class_name: 'Fabric::Charge', dependent: :destroy
    has_many :invoice_items, class_name: 'Fabric::InvoiceItem',
      dependent: :destroy
    has_many :usage_records, class_name: 'Fabric::UsageRecord'

    field :stripe_id, type: String
    field :created, type: Time
    field :account_balance, type: Integer, default: 0
    field :currency, type: String, default: 'usd'
    field :default_source, type: String
    field :delinquent, type: Boolean, default: false
    field :description, type: String
    field :email, type: String
    field :livemode, type: Boolean
    field :metadata, type: Hash
    field :discount, type: Hash

    validates_uniqueness_of :stripe_id
    validates :stripe_id, :created, presence: true
    validates :default_source, presence: true,
      if: proc { |c| c.sources.present? }

    index({ stripe_id: 1 }, { background: true, unique: true })

    before_destroy :delete_from_stripe

    def delete_from_stripe
      Stripe::Customer.retrieve(stripe_id).delete
    rescue Stripe::InvalidRequestError => e
      puts e.inspect.red
    end

    def sync_with(cust)
      self.stripe_id = Fabric.stripe_id_for cust
      self.created = cust.created
      self.account_balance = cust.account_balance
      self.currency = cust.currency
      self.default_source = cust.default_source
      # self.sources = cust.sources
      self.delinquent = cust.delinquent
      self.description = cust.description
      self.email = cust.email
      self.livemode = cust.livemode
      self.metadata = convert_metadata(cust.metadata.to_hash)
      self.discount = cust.discount.try(:to_hash)
      self
    end

    def source
      sources.find_by(stripe_id: default_source)
    end

    def plan
      Fabric::BillingPolicy.new(self).plan
    end

  end
end
