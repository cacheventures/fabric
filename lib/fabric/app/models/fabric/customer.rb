module Fabric
  class Customer
    include Mongoid::Document
    include Mongoid::Timestamps
    extend Enumerize

    has_many :subscriptions, class_name: 'Fabric::Subscription',
      primary_key: :stripe_id, dependent: :destroy
    has_many :sources, class_name: 'Fabric::Card',
      primary_key: :stripe_id, dependent: :destroy
    has_many :invoices, class_name: 'Fabric::Invoice',
      primary_key: :stripe_id, dependent: :destroy
    has_many :events, class_name: 'Fabric::Event', inverse_of: :customer,
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

    field :stripe_id, type: String
    field :object, type: String
    field :address, type: Hash
    field :balance, type: Integer, default: 0
    field :created, type: Time
    field :currency, type: String, default: 'usd'
    field :default_source, type: String
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
    validates :stripe_id, :created, presence: true
    validates :default_source, presence: true,
      if: proc { |c| c.sources.present? }

    index({ stripe_id: 1 }, { background: true, unique: true })

    def sync_with(cust)
      self.stripe_id = Fabric.stripe_id_for cust
      self.object = cust.object
      self.address = cust.address.try(:to_hash)
      self.balance = cust.balance
      self.created = cust.created
      self.currency = cust.currency
      self.default_source = cust.default_source
      self.delinquent = cust.delinquent
      self.description = cust.description
      self.discount = cust.discount.try(:to_hash)
      self.email = cust.email
      self.invoice_prefix = cust.invoice_prefix
      self.invoice_settings = cust.invoice_settings.try(:to_hash)
      self.livemode = cust.livemode
      self.metadata = Fabric.convert_metadata(cust.metadata.to_hash)
      self.name = cust.name
      self.phone = cust.phone
      self.preferred_locales = cust.preferred_locales
      self.shipping = cust.shipping.try(:to_hash)
      self.tax_exempt = cust.tax_exempt
      self
    end

    def source
      sources.find_by(stripe_id: default_source)
    end

  end
end
