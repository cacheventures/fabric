module Fabric
  module Webhooks
    class PaymentMethodDetached
      include Fabric::Webhook

      def call(event)
        check_idempotence(event) or return if Fabric.config.store_events
        handle(event)
        persist_model(event) if Fabric.config.persist?(:payment_method)
      end

      def persist_model(event)
        payment_method = retrieve_local(
          :payment_method, event['data']['object']['id']
        )
        return unless payment_method

        destroyed = payment_method.destroy

        log_data = {
          class: self.class.name, payment_method: payment_method.stripe_id,
          destroyed: destroyed
        }
        flogger.json_info 'Deleted', log_data
      end
    end
  end
end
