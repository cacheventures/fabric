module Fabric
  class PaymentIntent
    include Base
    include Mongoid::Document
    include Mongoid::Timestamps

    belongs_to :customer, class_name: 'Fabric::Customer',
      primary_key: :stripe_id
    belongs_to :invoice, class_name: 'Fabric::Invoice',
      primary_key: :stripe_id
    has_many :charges, class_name: 'Fabric::Charge',
      primary_key: :stripe_id, dependent: :destroy
    has_one :review, class_name: 'Fabric::Review', primary_key: :stripe_id

    field :stripe_id, type: String
    field :object, type: String
    field :amount, type: Integer
    field :amount_capturable, type: Integer
    field :amount_received, type: Integer
    field :application, type: String
    field :application_fee_amount, type: Integer
    field :canceled_at, type: Time
    field :cancellation_reason, type: String
    field :capture_method, type: String
    field :client_secret, type: String
    field :confirmation_method, type: String
    field :created, type: Time
    field :currency, type: String
    field :description, type: String
    field :last_payment_error, type: Hash
    field :livemode, type: Boolean
    field :metadata, type: Hash
    field :next_action, type: Hash
    field :on_behalf_of, type: String
    field :payment_method, type: String
    field :payment_method_options, type: Hash
    field :payment_method_types, type: Array
    field :receipt_email, type: String
    field :setup_future_usage, type: String
    field :shipping, type: Hash
    field :statement_descriptor, type: String
    field :statement_descriptor_suffix, type: String
    field :status, type: String
    field :transfer_data, type: Hash
    field :transfer_group, type: String

    validates_uniqueness_of :stripe_id
    validates :stripe_id, presence: true

    index({ stripe_id: 1 }, { background: true, unique: true })

    def sync_with(payment_intent)
      self.stripe_id = stripe_id_for(payment_intent)
      self.object = payment_intent.object
      self.amount = payment_intent.amount
      self.amount_capturable = payment_intent.amount_capturable
      self.amount_received = payment_intent.amount_received
      self.application = payment_intent.application
      self.application_fee_amount = payment_intent.application_fee_amount
      self.canceled_at = payment_intent.canceled_at
      self.cancellation_reason = payment_intent.cancellation_reason
      self.capture_method = payment_intent.capture_method
      self.client_secret = payment_intent.client_secret
      self.confirmation_method = payment_intent.confirmation_method
      self.created = payment_intent.created
      self.currency = payment_intent.currency
      self.customer_id = handle_expanded(payment_intent.customer)
      self.description = payment_intent.description
      self.invoice_id = handle_expanded(payment_intent.invoice)
      self.last_payment_error = handle_hash(payment_intent.last_payment_error)
      self.livemode = payment_intent.livemode
      self.metadata = convert_metadata(payment_intent.metadata)
      self.on_behalf_of = payment_intent.on_behalf_of
      self.payment_method = handle_expanded(payment_intent.payment_method)
      self.payment_method_options =
        handle_hash(payment_intent.payment_method_options)
      self.payment_method_types = payment_intent.payment_method_types
      self.receipt_email = payment_intent.receipt_email
      self.setup_future_usage = payment_intent.setup_future_usage
      self.shipping = handle_hash(payment_intent.shipping)
      self.statement_descriptor = payment_intent.statement_descriptor
      self.statement_descriptor_suffix = payment_intent.statement_descriptor_suffix
      self.status = payment_intent.status
      self.transfer_data = handle_hash(payment_intent.transfer_data)
      self.transfer_group = payment_intent.transfer_group
      self
    end

  end
end
