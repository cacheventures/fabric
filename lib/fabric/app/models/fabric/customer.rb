module Fabric
  class Customer
    include Base
    include Mongoid::Document
    include Mongoid::Timestamps

    has_many :subscriptions, class_name: 'Fabric::Subscription',
      primary_key: :stripe_id, dependent: :destroy
    has_many :sources, class_name: 'Fabric::Source',
      primary_key: :stripe_id, dependent: :destroy
    has_many :invoices, class_name: 'Fabric::Invoice',
      primary_key: :stripe_id, dependent: :destroy
    has_many :events, class_name: 'Fabric::Event',
      primary_key: :stripe_id, dependent: :destroy
    has_many :charges, class_name: 'Fabric::Charge',
      primary_key: :stripe_id, dependent: :destroy
    has_many :invoice_items, class_name: 'Fabric::InvoiceItem',
      primary_key: :stripe_id, dependent: :destroy
    has_many :usage_records, class_name: 'Fabric::UsageRecord',
      primary_key: :stripe_id, dependent: :destroy
    has_many :payment_methods, class_name: 'Fabric::PaymentMethod',
      primary_key: :stripe_id, dependent: :destroy
    has_many :setup_intents, class_name: 'Fabric::SetupIntent',
      primary_key: :stripe_id, dependent: :destroy
    has_many :payment_intents, class_name: 'Fabric::PaymentIntent',
      primary_key: :stripe_id, dependent: :destroy
    has_many :tax_ids, class_name: 'Fabric::TaxId',
      primary_key: :stripe_id, dependent: :destroy

    embeds_one :funding_instructions, class_name: 'Fabric::FundingInstructions'

    field :stripe_id, type: String
    field :object, type: String
    field :account_balance, type: Integer, default: 0 # deprecated
    field :address, type: Hash
    field :balance, type: Integer, default: 0
    field :created, type: Time
    field :currency, type: String, default: 'usd'
    field :default_source, type: String
    field :deleted, type: Boolean
    field :delinquent, type: Boolean, default: false
    field :description, type: String
    field :discount, type: Hash
    field :email, type: String
    field :invoice_prefix, type: String
    field :invoice_settings, type: Hash
    field :livemode, type: Boolean
    field :metadata, type: Hash
    field :name, type: String
    field :phone, type: String
    field :preferred_locales, type: Array
    field :shipping, type: Hash
    field :tax_exempt, type: String

    validates_uniqueness_of :stripe_id
    validates :stripe_id, presence: true
    validates :default_source, presence: true,
      if: proc { |c| c.sources.present? }

    index({ stripe_id: 1 }, { background: true, unique: true })

    def sync_with(cust)
      self.stripe_id = cust.id
      self.object = cust.object
      self.deleted = cust.deleted?
      if cust.deleted?
        self.account_balance = nil
        self.address = nil
        self.balance = nil
        self.created = nil
        self.currency = nil
        self.default_source = nil
        self.delinquent = nil
        self.description = nil
        self.discount = nil
        self.email = nil
        self.invoice_prefix = nil
        self.invoice_settings = nil
        self.livemode = nil
        self.metadata = nil
        self.name = nil
        self.phone = nil
        self.preferred_locales = nil
        self.shipping = nil
        self.tax_exempt = nil
      else
        self.account_balance = cust.account_balance
        self.address = handle_hash(cust.address)
        self.balance = cust.balance
        self.created = cust.created
        self.currency = cust.currency
        self.default_source = cust.default_source
        self.delinquent = cust.delinquent
        self.description = cust.description
        self.discount = handle_hash(cust.discount)
        self.email = cust.email
        self.invoice_prefix = cust.invoice_prefix
        self.invoice_settings =
          handle_hash(cust.invoice_settings)
        self.livemode = cust.livemode
        self.metadata = convert_metadata(cust.metadata)
        self.name = cust.name
        self.phone = cust.phone
        self.preferred_locales = cust.preferred_locales
        self.shipping = handle_hash(cust.shipping)
        self.tax_exempt = cust.tax_exempt
      end
      self
    end

    def source
      sources.find_by(stripe_id: default_source)
    end

  end
end
