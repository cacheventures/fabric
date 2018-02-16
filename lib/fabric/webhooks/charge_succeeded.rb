module Fabric
  module Webhooks
    class ChargeSucceeded
      include Fabric::Webhook

      def call(event)
        if Fabric.config.store_events
          check_idempotency(event) or return
        end

        handle(event)
      end
    end
  end
end
