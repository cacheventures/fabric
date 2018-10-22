module Fabric
  module Webhook

    # @param event a Stripe event from a webhook
    # @return [Array<Fabric::Event, Boolean>] whether it existed,
    #   for idempotency checking
    def create_event(event, customer_id)
      event = Fabric::Event.find_or_initialize_by(
        stripe_id: event[:id],
        webhook: event[:type],
        customer_id: customer_id
      )
      event.api_version = event[:api_version]
      previously_existed = event.persisted?
      event.save unless previously_existed
      [event, previously_existed]
    end

    # check idempotency of an event, returning false if we already processed
    # this event, so the caller may return out. discards the created
    # event reference.
    #
    # @param event a Stripe event from a webhook
    # @return [Boolean] true if validated
    def check_idempotency(event, customer_id = nil)
      _fabric_event, existed = create_event(event, customer_id)
      if existed
        Fabric.config.logger.info "#{event[:type]}: Event already exists"
        return false
      end
      true
    end

    # retrieves the local resource if it exists.
    #
    # @param resource_name name of local model
    # @param remote_id a Stripe ID for the resource
    # @return [Fabric::resource] the local resource if exists
    def retrieve_local(resource_name, remote_id)
      resource = "Fabric::#{resource_name.capitalize}".constantize.find_by(
        stripe_id: remote_id
      )
      unless resource.present?
        log_data = { name: resource_name, remote_id: remote_id }
        Fabric.config.logger.info("resource not found #{log_data.to_json}")
        return
      end
      resource
    end

    # check if the event is more up to date then the local resource
    #
    # @param resource the local resource
    # @param event the incoming event
    # @return [Boolean] true if the event is most recent update
    def most_recent_update?(resource, event)
      x = Time.at(event.created) >= resource.updated_at
      log_data = { id: resource.id.to_s, name: resource.class.name }
      Fabric.config.logger.info("skipping update #{log_data.to_json}") unless x
      x
    end

    # handle an event with custom user code.
    # stub method, override on a per-class basis if custom behavior is desired.
    # @param event a Stripe event from a webhook
    def handle(event); end

  end
end
