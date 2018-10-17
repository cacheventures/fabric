module Fabric
  module Webhooks
    class DisputeCreated
      include Fabric::Webhook

      def call(event)
        check_idempotency(event) or return if Fabric.config.store_events
        persist_model(event) if Fabric.config.persist?(:dispute)
        handle(event)
      end

      def persist_model(event)
        # TODO
      end

    end
  end
end
