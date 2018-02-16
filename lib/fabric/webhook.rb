module Fabric
  module Webhook

    # @param event a Stripe event from a webhook
    # @return [Array<Fabric::Event, Boolean>] whether it existed,
    #   for idempotency checking
    def create_event(event)
      event = Fabric::Event.find_or_initialize_by(
        stripe_id: event[:id],
        webhook: event[:type]
      )
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
    def check_idempotency(event)
      _fabric_event, existed = create_event event
      if existed
        Fabric.config.logger.info "#{event[:type]}: Event already exists"
        return false
      end
      true
    end

    # handle an event with custom user code.
    # stub method, override on a per-class basis if custom behavior is desired.
    # @param event a Stripe event from a webhook
    def handle(event); end

  end
end
