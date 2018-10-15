module Fabric
  module Webhooks
    class PaymentSucceeded
      include Fabric::Webhook

      def call(event)
        if Fabric.config.store_events
          check_idempotency(event) or return
        end

        persist_model(event) if Fabric.config.persist?(:dispute)

        handle(event)
      end

      def persist_model(event)
        # TODO
      end

    end
  end
end
