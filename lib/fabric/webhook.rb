module Fabric
  module Webhook
    include Fabric

    # @param event a Stripe event from a webhook
    # @return [Array<Fabric::Event, Boolean>] whether it existed,
    #   for idempotence checking
    def create_event(event, customer_id)
      fabric_event = Fabric::Event.find_or_initialize_by(
        stripe_id: event['id'],
        webhook: event['type'],
        customer_id: customer_id
      )
      fabric_event.api_version = event['api_version']
      previously_existed = fabric_event.persisted?
      fabric_event.save unless previously_existed
      [fabric_event, previously_existed]
    end

    # check idempotence of an event, returning false if we already processed
    # this event, so the caller may return out. discards the created
    # event reference.
    #
    # @param event a Stripe event from a webhook
    # @return [Boolean] true if validated
    def check_idempotence(event, customer_id = nil)
      _fabric_event, existed = create_event(event, customer_id)
      if existed
        flogger.json_info('Event already exists', event: event[:type])
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
      resource = "Fabric::#{resource_name.to_s.camelcase}".constantize.find_by(
        stripe_id: remote_id
      )
      unless resource.present?
        log_data = { name: resource_name, remote_id: remote_id }
        flogger.json_info('resource not found', log_data)
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
      x = Time.at(event['created']) >= resource.updated_at
      log_data = { id: resource.id.to_s, name: resource.class.name }
      flogger.json_info('skipping update', log_data) unless x
      x
    end

    # retrieve a resource from Stripe
    #
    # @param resource name of Stripe resource
    # @param resource_id id of resource to retrieve from Stripe
    # @return [Stripe::APIResource, nil] returns the Stripe::Resource if able and nil otherwise
    def retrieve_resource(resource, resource_id)
      log_data = { resource: resource, resource_id: resource_id }
      "Stripe::#{resource.camelcase}".constantize.retrieve(resource_id)
    rescue Stripe::InvalidRequestError => e
      log_data[:error] = e.inspect
      flogger.json_info('couldn\'t retrieve resource', log_data)
    end

    # handle an event with custom user code.
    # stub method, override on a per-class basis if custom behavior is desired.
    # @param event a Stripe event from a webhook
    def handle(event, stripe_resource = nil); end

  end
end
