module Fabric
  class PaymentMethod
    include Mongoid::Document
    include Mongoid::Timestamps

    belongs_to :customer, class_name: 'Fabric::Customer',
      primary_key: :stripe_id
    has_many :subscriptions, class_name: 'Fabric::Subscription',
      primary_key: :stripe_id

    field :stripe_id, type: String

    # different types each have a hash with their name as the key. only one
    # will exist at a time.
    field :au_becs_debit, type: Hash
    field :bacs_debit, type: Hash
    field :bancontact, type: Hash
    field :card, type: Hash
    field :card_present, type: Hash
    field :eps, type: Hash
    field :fpx, type: Hash
    field :giropay, type: Hash
    field :ideal, type: Hash
    field :p24, type: Hash
    field :sepa_debit, type: Hash

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
      self.stripe_id = Fabric.stripe_id_for payment_method

      self.au_becs_debit = payment_method.try(:au_becs_debit)&.to_hash&.with_indifferent_access
      self.bacs_debit = payment_method.try(:bacs_debit)&.to_hash&.with_indifferent_access
      self.bancontact = payment_method.try(:bancontact)&.to_hash&.with_indifferent_access
      self.card = payment_method.try(:card)&.to_hash&.with_indifferent_access
      self.card_present = payment_method.try(:card_present)&.to_hash&.with_indifferent_access
      self.eps = payment_method.try(:eps)&.to_hash&.with_indifferent_access
      self.fpx = payment_method.try(:fpx)&.to_hash&.with_indifferent_access
      self.giropay = payment_method.try(:giropay)&.to_hash&.with_indifferent_access
      self.ideal = payment_method.try(:ideal)&.to_hash&.with_indifferent_access
      self.p24 = payment_method.try(:p24)&.to_hash&.with_indifferent_access
      self.sepa_debit = payment_method.try(:sepa_debit)&.to_hash&.with_indifferent_access

      self.object = payment_method.object
      self.billing_details =
        payment_method.billing_details&.to_hash&.with_indifferent_access
      self.created = payment_method.created
      self.customer_id = payment_method.customer
      self.livemode = payment_method.livemode
      self.metadata = Fabric.convert_metadata(payment_method.metadata)
      self.type = payment_method.type
      self
    end

    # helpful for displaying the brand the previous way that it was done
    # with cards. the new way isn't user friendly.
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
