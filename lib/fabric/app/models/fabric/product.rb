module Fabric
  class Product
    include Mongoid::Document
    include Mongoid::Timestamps
    extend Enumerize

    has_many :prices, class_name: 'Fabric::Price', dependent: :nullify

    field :stripe_id, type: String
    field :active, type: Boolean
    field :product_attributes, type: Array # stripe field name is attributes
    field :caption, type: String
    field :created, type: Time
    field :deactivate_on, type: Array
    field :description, type: String
    field :images, type: Array
    field :livemode, type: Boolean
    field :package_dimensions, type: Hash
    field :shippable, type: Boolean
    field :metadata, type: Hash
    field :name, type: String
    field :statement_descriptor, type: String
    field :type, type: String
    field :unit_label, type: String
    field :updated, type: Date
    field :url, type: String

    validates_uniqueness_of :stripe_id
    validates :stripe_id, :name, presence: true

    index({ stripe_id: 1 }, { background: true, unique: true })

    def sync_with(product)
      self.stripe_id = Fabric.stripe_id_for product
      self.active = product.active
      self.product_attributes = product_attributes_for(product)
      self.caption = product.try(:caption)
      self.created = product.created
      self.deactivate_on = product.try(:deactivate_on)
      self.description = product.description
      self.images = product.images
      self.livemode = product.livemode
      self.package_dimensions = product.try(:package_dimensions).try(:to_hash)
      self.shippable = product.try(:shippable)
      self.metadata = Fabric.convert_metadata(product.metadata.to_hash)
      self.name = product.name
      self.statement_descriptor = product.statement_descriptor
      self.type = product.type
      self.unit_label = product.unit_label
      self.updated = product.updated
      self.url = product.try(:url)
      self
    end

    private

    def product_attributes_for(product)
      if product.is_a?(Stripe::APIResource)
        product.attributes
      elsif product.is_a?(Mongoid::Document)
        product.product_attributes
      else
        fail InvalidResourceError, product
      end
    end

  end
end
