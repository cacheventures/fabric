module Fabric
  class SetupIntent
    include Mongoid::Document
    include Mongoid::Timestamps

    belongs_to :customer, class_name: 'Fabric::Customer'

    field :stripe_id, type: String
    field :object, type: String
    field :application, type: String
    field :cancellation_reason, type: String
    field :client_secret, type: String
    field :created, type: Time
    field :description, type: String
    field :last_setup_error, type: Hash
    field :livemode, type: Boolean
    field :metadata, type: Hash
    field :next_action, type: Hash
    field :on_behalf_of, type: String
    field :payment_method, type: String
    field :payment_method_options, type: Hash
    field :payment_method_types, type: Array
    field :status, type: String
    field :usage, type: String

    def sync_with(setup_intent)
      self.stripe_id = Fabric.stripe_id_for(setup_intent)
      self.object = setup_intent.object
      self.application = setup_intent.application
      self.cancellation_reason = setup_intent.cancellation_reason
      self.client_secret = setup_intent.client_secret
      self.created = setup_intent.created
      self.customer = Fabric::Customer.find_by(
        stripe_id: setup_intent.customer
      ) unless customer.present?
      self.description = setup_intent.description
      self.last_setup_error = setup_intent.last_setup_error.try(:to_hash)
      self.livemode = setup_intent.livemode
      self.metadata = Fabric.convert_metadata(setup_intent.metadata.to_hash)
      self.next_action = setup_intent.next_action.try(:to_hash)
      self.on_behalf_of = setup_intent.on_behalf_of
      self.payment_method = setup_intent.payment_method
      self.payment_method_options = setup_intent.payment_method_options.try(:to_hash)
      self.payment_method_types = setup_intent.payment_method_types
      self.status = setup_intent.status
      self.usage = setup_intent.usage
    end
  end
end
