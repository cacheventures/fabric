module Fabric
  class CreateSetupIntentOperation
    include Fabric

    def initialize(attributes)
      @log_data = { class: self.class.name, attributes: attributes }
      flogger.json_info 'Started', @log_data

      @attributes = attributes
    end

    def call
      stripe_setup_intent = Stripe::SetupIntent.create(@attributes)
      setup_intent = Fabric::SetupIntent.new
      setup_intent.sync_with(stripe_setup_intent)
      saved = setup_intent.save

      flogger.json_info 'Completed', @log_data.merge(saved: saved)
      [setup_intent, stripe_setup_intent]
    end

  end
end
