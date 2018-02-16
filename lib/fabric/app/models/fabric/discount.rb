module Fabric
  class Discount
    include Mongoid::Document
    include Mongoid::Timestamps
    extend Enumerize

    belongs_to :customer, class_name: 'Fabric::Customer'
    belongs_to :subscription, class_name: 'Fabric::Subscription'

    field :end, type: Time
    field :start, type: Time
    field :coupon, type: Hash

    validates :start, :customer, :coupon, presence: true

    def sync_with(discount)
      self.end = discount.end
      self.start = discount.start
      self.coupon = discount.coupon.to_hash
      self.subscription = Fabric::Subscription.find_by(
        stripe_id: discount.subscription
      ) if discount.subscription.present?
      self.customer = Fabric::Customer.find_by(
        stripe_id: discount.customer
      ) unless customer.present?
      self
    end
  end
end
