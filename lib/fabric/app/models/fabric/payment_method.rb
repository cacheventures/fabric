module Fabric
  class PaymentMethod
    include Mongoid::Document
    include Mongoid::Timestamps

    belongs_to :customer, class_name: 'Fabric::Customer'

    field :stripe_id, type: String
    field :object, type: String
    field :billing_details, type: Hash
    field :card, type: Hash
    field :created, type: Time
    field :livemode, type: Boolean
    field :metadata, type: Hash
    field :type, type: String

    validates_uniqueness_of :stripe_id
    validates :stripe_id, presence: true

    index({ stripe_id: 1 }, { background: true, unique: true })

    def sync_with(payment_method)
      self.stripe_id = Fabric.stripe_id_for payment_method
      self.object = payment_method.object
      self.billing_details = payment_method.billing_details.try(:to_hash)
      self.card = payment_method.card.try(:to_hash)
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
