module Fabric
  class PaymentIntent
    include Mongoid::Document
    include Mongoid::Timestamps

    belongs_to :customer, class_name: 'Fabric::Customer'
    has_many :charges, class_name: 'Fabric::Charge', dependent: :destroy

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
    field :invoice, type: String
    field :last_payment_error, type: Hash
    field :livemode, type: Boolean
    field :metadata, type: Hash
    field :next_action, type: Hash
    field :on_behalf_of, type: String
    field :payment_method, type: String
    field :payment_method_options, type: Hash
    field :payment_method_types, type: Array
    field :receipt_email, type: String
    field :review, type: String
    field :setup_future_usage, type: String
    field :shipping, type: Hash
    field :statement_descriptor, type: String
    field :statement_descriptor_suffix, type: String
    field :status, type: String
    field :transfer_data, type: Hash
    field :transfer_group, type: String

    def sync_with(payment_intent)
      self.stripe_id = Fabric.stripe_id_for(payment_intent)
      self.object = payment_intent.object
      self.amount = payment_intent.amount
      self.amount_capturable = payment_intent.amount_capturable
      self.amount_received = payment_intent.amount_received
      self.application = payment_intent.application
      self.application_fee_amount = payment_intent.application_fee_amount
      self.canceled_at = payment_intent.canceled_at
      self.cancellation_reason = payment_intent.cancellation_reason
      self.capture_method = payment_intent.capture_method
      payment_intent.charges.data.each do |charge|
        c = charges.find_by(stripe_id: charge.id) || charges.build
        c.sync_with(charge)
        c.save
      end
      self.client_secret = payment_intent.client_secret
      self.confirmation_method = payment_intent.confirmation_method
      self.created = payment_intent.created
      self.currency = payment_intent.currency
      self.customer = Fabric::Customer.find_by(
        stripe_id: payment_intent.customer
      ) unless customer.present?
      self.description = payment_intent.description
      self.invoice = Fabric::Invoice.find_by(
        stripe_id: payment_intent.invoice
      ) unless invoice.present?
      self.last_payment_error = payment_intent.last_payment_error.try(:to_hash)
      self.livemode = payment_intent.livemode
      self.metadata = Fabric.convert_metadata(payment_intent.metadata.to_hash)
      self.on_behalf_of = payment_intent.on_behalf_of
      self.payment_method = payment_intent.payment_method
      self.payment_method_options = payment_intent.payment_method_options.try(:to_hash)
      self.payment_method_types = payment_intent.payment_method_types
      self.receipt_email = payment_intent.receipt_email
      self.review = payment_intent.review
      self.setup_future_usage = payment_intent.setup_future_usage
      self.shipping = payment_intent.shipping.try(:to_hash)
      self.statement_descriptor = payment_intent.statement_descriptor
      self.statement_descriptor_suffix = payment_intent.statement_descriptor_suffix
      self.status = payment_intent.status
      self.transfer_data = payment_intent.transfer_data.try(:to_hash)
      self.transfer_group = payment_intent.transfer_group
    end
  end
end
