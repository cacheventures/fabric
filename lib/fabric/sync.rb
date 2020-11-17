module Fabric
  module Sync
    module_function

    def from_fabric_model(document)
      stripe_class = resource.class.name.gsub('Fabric', 'Stripe').constantize
      resource = stripe_class.retrieve(document.stripe_id)
      document.sync_with(resource)
      document.save

      [document, resource]
    end

    def from_stripe_resource(resource)
      fabric_class = resource.class.name.gsub('Stripe', 'Fabric').constantize
      document = fabric_class.find_or_initialize_by(stripe_id: resource.id)
      document.sync_with(resource)
      document.save

      [document, resource]
    end

    def from_stripe_id(resource_name, stripe_id)
      class_name = resource_name.to_s.camelcase
      fabric_class = "Fabric::#{class_name}".constantize
      stripe_class = "Stripe::#{class_name}".constantize
      resource = stripe_class.retrieve(stripe_id)
      document = fabric_class.find_or_initialize_by(stripe_id: resource.id)
      document.sync_with(resource)
      document.save

      [document, resource]
    end

  end
end
