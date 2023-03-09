module Fabric
  module Base

    # method to retrieve the stripe object and sync it locally
    def sync_from_stripe
      return self unless stripe_id.present?

      stripe_name = self.class.name.split('::').last
      stripe_class = "Stripe::#{stripe_name}".constantize
      stripe_object = stripe_class.retrieve(stripe_id)
      sync_with(stripe_object)
      self
    end

    # automatically handle when we've expanded an object in the Stripe response
    def handle_expanded(object_or_id)
      return if object_or_id.nil?

      object_or_id.is_a?(String) ? object_or_id : object_or_id.id
    end

    # make sure all hashes are stored with_indifferent_access
    def handle_hash(hash)
      hash&.to_hash&.with_indifferent_access
    end

    def convert_metadata(stripe_metadata)
      hash = stripe_metadata&.to_hash || {}
      hash.transform_values do |value|
        if value.to_i.to_s == value
          value.to_i
        elsif value.to_f.to_s == value
          value.to_f
        elsif value.in? %w[true false]
          value == 'true' ? true : false
        else
          value
        end
      end.with_indifferent_access
    end

  end
end
