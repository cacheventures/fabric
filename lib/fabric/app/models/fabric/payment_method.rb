module Fabric
  class PaymentMethod
    include Mongoid::Document
    include Mongoid::Timestamps

    belongs_to :customer, class_name: 'Fabric::Customer'

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

      self.au_becs_debit = payment_method.try(:au_becs_debit).try(:to_hash)
      self.bacs_debit = payment_method.try(:bacs_debit).try(:to_hash)
      self.bancontact = payment_method.try(:bancontact).try(:to_hash)
      self.card = payment_method.try(:card).try(:to_hash)
      self.card_present = payment_method.try(:card_present).try(:to_hash)
      self.eps = payment_method.try(:eps).try(:to_hash)
      self.fpx = payment_method.try(:fpx).try(:to_hash)
      self.giropay = payment_method.try(:giropay).try(:to_hash)
      self.ideal = payment_method.try(:ideal).try(:to_hash)
      self.p24 = payment_method.try(:p24).try(:to_hash)
      self.sepa_debit = payment_method.try(:sepa_debit).try(:to_hash)

      self.object = payment_method.object
      self.billing_details = payment_method.billing_details.try(:to_hash)
      self.created = payment_method.created
      self.customer = Fabric::Customer.find_by(
        stripe_id: payment_method.customer
      ) unless customer.present?
      self.livemode = payment_method.livemode
      self.metadata = Fabric.convert_metadata(payment_method.metadata.to_hash)
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
