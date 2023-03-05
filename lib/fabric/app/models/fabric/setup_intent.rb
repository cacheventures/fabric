module Fabric
  class SetupIntent
    include Base
    include Mongoid::Document
    include Mongoid::Timestamps

    belongs_to :customer, class_name: 'Fabric::Customer',
      primary_key: :stripe_id

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

    validates_uniqueness_of :stripe_id
    validates :stripe_id, presence: true

    index({ stripe_id: 1 }, { background: true, unique: true })

    def sync_with(setup_intent)
      self.stripe_id = stripe_id_for(setup_intent)
      self.object = setup_intent.object
      self.application = setup_intent.application
      self.cancellation_reason = setup_intent.cancellation_reason
      self.client_secret = setup_intent.client_secret
      self.created = setup_intent.created
      self.customer_id = handle_expanded(setup_intent.customer)
      self.description = setup_intent.description
      self.last_setup_error = handle_hash(setup_intent.last_setup_error)
      self.livemode = setup_intent.livemode
      self.metadata = convert_metadata(setup_intent.metadata)
      self.next_action = handle_hash(setup_intent.next_action)
      self.on_behalf_of = setup_intent.on_behalf_of
      self.payment_method = handle_expanded(setup_intent.payment_method)
      self.payment_method_options =
        handle_hash(setup_intent.payment_method_options)
      self.payment_method_types = setup_intent.payment_method_types
      self.status = setup_intent.status
      self.usage = setup_intent.usage
    end
  end
end
