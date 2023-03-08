module Fabric
  class Event
    include Base
    include Mongoid::Document
    include Mongoid::Timestamps

    belongs_to :customer, class_name: 'Fabric::Customer',
      primary_key: :stripe_id, touch: true

    field :stripe_id, type: String
    field :api_version, type: String
    field :created, type: Integer
    field :data, type: Hash, default: {}
    field :livemode, type: Boolean
    field :request, type: Hash
    field :webhook, type: String

    validates_uniqueness_of :stripe_id
    validates_presence_of :api_version, :webhook

    index({ stripe_id: 1 }, { background: true, unique: true })
    index({ webhook: 1, customer_id: 1 }, background: true)

    def sync_with(event)
      self.api_version = event.api_version
      self.created = event.created
      event_data = handle_hash(event.data)
      self.data = event_data if Fabric.config.store_event_data
      self.livemode = event.livemode
      self.request = handle_hash(event.request)
      self.customer_id = Fabric::Event.extract_customer_id(event_data)
      self
    end

    # this actually is the stupid structure of event['data']
    # {
    #   object: {
    #     object: 'customer/setup_intent/payment_intent.etc',
    #     customer_id: 'cus_xxx'
    #   }
    # }
    def self.extract_customer_id(event_data)
      object = event_data['object']
      object['object'] == 'customer' ? object['id'] : object['customer']
    end

  end
end
