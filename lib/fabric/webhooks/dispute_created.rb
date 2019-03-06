module Fabric
  module Webhooks
    class DisputeCreated
      include Fabric::Webhook

      def call(event)
        check_idempotence(event) or return if Fabric.config.store_events
        handle(event)
        persist_model(event) if Fabric.config.persist?(:dispute)
      end

      def persist_model(event)
        # TODO
      end

    end
  end
end
