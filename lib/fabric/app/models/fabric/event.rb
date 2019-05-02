module Fabric
  class Event
    include Mongoid::Document
    include Mongoid::Timestamps

    belongs_to :customer, class_name: 'Fabric::Customer', inverse_of: :events,
      touch: true

    field :stripe_id, type: String
    field :api_version, type: String
    field :created, type: Integer
    field :data, type: Hash, default: {}
    field :livemode, type: Boolean
    field :request, type: String
    field :webhook, type: String

    validates_uniqueness_of :stripe_id
    validates_presence_of :api_version, :webhook

    index({ stripe_id: 1 }, { background: true, unique: true })
    index({ webhook: 1, customer_id: 1 }, background: true)

    # stripe_id and webhook cannot be obtained from event.data.object, so
    # events must be initialized with them before running #from
    def sync_with(event)
      self.api_version = event[:api_version]
      self.created = event[:created]
      self.data = event[:data]
      self.livemode = event[:livemode]
      self.request = event[:request]
      customer_id = event[:object] == 'customer' ? event[:id] : event[:customer]
      self.customer = Fabric::Customer.find_by(
        stripe_id: customer_id
      ) unless customer.present?
      self
    end

    def stripe_object_id
      data.try(:[], :object).try(:[], :id)
    end

    # get stripe customer id from data.object
    # TODO: test if not tested
    def stripe_customer
      if is_customer?
        data[:object].try(:[], :id)
      else # object == 'subscription', etc.
        data[:object].try(:[], :customer)
      end
    end

    private

    def is_customer?
      data[:object].try(:[], :object) == 'customer'
    end

  end
end
