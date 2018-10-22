module Fabric
  class Card
    include Mongoid::Document
    include Mongoid::Timestamps
    extend Enumerize

    belongs_to :customer, class_name: 'Fabric::Customer', inverse_of: :sources,
      touch: true

    field :stripe_id, type: String
    field :last4, type: String
    field :brand, type: String
    enumerize :brand, in: ['Visa', 'American Express', 'MasterCard',
                           'Discover', 'JCB', 'Diners Club', 'Unknown']
    field :exp_month, type: Integer
    field :exp_year, type: Integer
    field :fingerprint, type: String
    field :funding, type: String
    enumerize :funding, in: %w(credit debit prepaid unknown)
    field :country, type: String
    field :name, type: String
    field :address_line1, type: String
    field :address_line2, type: String
    field :address_city, type: String
    field :address_state, type: String
    field :address_zip, type: String
    field :address_country, type: String
    field :cvc_check, type: String
    field :address_line1_check, type: String
    field :address_zip_check, type: String
    field :dynamic_last4, type: String
    field :metadata, type: Hash
    field :tokenization_method, type: String

    validates_uniqueness_of :stripe_id
    validates :stripe_id, :customer, :last4, :brand, :exp_month, :exp_year,
      presence: true

    index({ stripe_id: 1 }, { background: true, unique: true })
    index({ customer_id: 1 }, background: true)

    def sync_with(card)
      self.stripe_id = Fabric.stripe_id_for card
      self.last4 = card.last4
      self.brand = card.brand
      self.funding = card.funding
      self.exp_month = card.exp_month
      self.exp_year = card.exp_year
      self.fingerprint = card.fingerprint
      self.country = card.country
      self.name = card.name
      self.address_line1 = card.address_line1
      self.address_line2 = card.address_line2
      self.address_city = card.address_city
      self.address_state = card.address_state
      self.address_zip = card.address_zip
      self.address_country = card.address_country
      self.cvc_check = card.cvc_check
      self.address_line1_check = card.address_line1_check
      self.address_zip_check = card.address_zip_check
      self.dynamic_last4 = card.dynamic_last4
      self.metadata = convert_metadata(card.metadata.to_hash)
      self.tokenization_method = card.tokenization_method
      unless customer.present?
        self.customer = Fabric::Customer.find_by(
          stripe_id: card.customer
        )
      end
      self
    end
  end
end
