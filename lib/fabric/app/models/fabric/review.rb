module Fabric
  class Review
    include Mongoid::Document
    include Mongoid::Timestamps

    belongs_to :charge, class_name: 'Fabric::Charge',
      primary_key: :stripe_id
    belongs_to :payment_intent, class_name: 'Fabric::PaymentIntent',
      primary_key: :stripe_id

    field :stripe_id, type: String
    field :charge_id, type: String
    field :payment_intent_id, type: String
    field :reason, type: String
    field :billing_zip, type: String
    field :closed_reason, type: String
    field :created, type: Time
    field :ip_address, type: String
    field :ip_address_location, type: Hash
    field :opened_reason, type: String
    field :session, type: Hash
    field :livemode, type: Boolean

    validates_uniqueness_of :stripe_id
    validates :stripe_id, presence: true

    index({ stripe_id: 1 }, { background: true, unique: true })

    def sync_with(review)
      self.stripe_id = Fabric.stripe_id_for review
      self.charge_id = review.charge
      self.payment_intent_id = review.payment_intent
      self.reason = review.reason
      self.billing_zip = review.billing_zip
      self.closed_reason = review.closed_reason
      self.created = review.created
      self.ip_address = review.ip_address
      self.ip_address_location =
        review.ip_address_location&.to_hash&.with_indifferent_access
      self.opened_reason = review.opened_reason
      self.session = review.session&.to_hash&.with_indifferent_access
      self.livemode = review.livemode
      self
    end

  end
end
