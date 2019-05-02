module Fabric
  class UsageRecord
    include Mongoid::Document
    include Mongoid::Timestamps

    belongs_to :customer, class_name: 'Fabric::Customer'
    belongs_to :subscription_item, class_name: 'Fabric::SubscriptionItem'

    field :stripe_id, type: String
    field :quantity, type: Integer
    field :timestamp, type: Time

    validates_uniqueness_of :stripe_id
    validates_presence_of :stripe_id, :quantity, :timestamp

    index({ stripe_id: 1 }, { background: true, unique: true })

    def sync_with(usage_record)
      self.stripe_id = Fabric.stripe_id_for(usage_record)
      self.quantity = usage_record.quantity
      self.timestamp = usage_record.timestamp
      self.subscription_item = Fabric::SubscriptionItem.find_by(
        stripe_id: usage_record.subscription_item
      )
      self
    end
  end
end
