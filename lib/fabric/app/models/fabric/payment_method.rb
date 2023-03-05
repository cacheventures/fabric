module Fabric
  class PaymentMethod
    include Base
    include Mongoid::Document
    include Mongoid::Timestamps

    SUPPORTED_PAYMENT_METHODS = %i(
      acss_debit affirm afterpay_clearpay alipay au_becs_debit bacs_debit
      bancontact blik boleto card card_present customer_balance eps fpx giropay
      grabpay ideal interac_present klarna konbini link oxxo p24 paynow pix
      promptpay sepa_debit sofort us_bank_account wechat_pay
    )

    belongs_to :customer, class_name: 'Fabric::Customer',
      primary_key: :stripe_id
    has_many :subscriptions, class_name: 'Fabric::Subscription',
      primary_key: :stripe_id

    field :stripe_id, type: String

    # different types each have a hash with their name as the key. only one
    # will exist at a time.
    SUPPORTED_PAYMENT_METHODS.each do |name|
      field name, type: Hash
    end

    field :object, type: String
    field :billing_details, type: Hash
    field :created, type: Time
    field :livemode, type: Boolean
    field :metadata, type: Hash
    field :type, type: String

    validates_uniqueness_of :stripe_id
    validates :stripe_id, presence: true

    index({ stripe_id: 1 }, { background: true, unique: true })

    def sync_with(payment_method)
      self.stripe_id = stripe_id_for(payment_method)

      SUPPORTED_PAYMENT_METHODS.each do |name|
        self[name] = handle_hash(payment_method.try(name))
      end

      self.object = payment_method.object
      self.billing_details = handle_hash(payment_method.billing_details)
      self.created = payment_method.created
      self.customer_id = handle_expanded(payment_method.customer)
      self.livemode = payment_method.livemode
      self.metadata = convert_metadata(payment_method.metadata)
      self.type = payment_method.type
      self
    end

    # helpful for displaying the brand the previous way that it was done with
    # cards. the new way isn't user friendly.
    def card_brand
      return nil unless card.present?

      {
        amex: 'American Express',
        diners: 'Diners Club',
        discover: 'Discover',
        jcb: 'JCB',
        mastercard: 'MasterCard',
        unionpay: 'UnionPay',
        visa: 'Visa',
        unknown: 'Unknown'
      }[card[:brand].to_sym]
    end

  end
end
