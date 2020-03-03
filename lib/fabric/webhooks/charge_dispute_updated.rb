module Fabric
  module Webhooks
    class ChargeDisputeUpdated
      include Fabric::Webhook

      def call(event)
        check_idempotence(event) or return if Fabric.config.store_events
        stripe_dispute = retrieve_resource(
          'dispute', event['data']['object']['id']
        )
        return if stripe_dispute.nil?

        handle(event, stripe_dispute)
        persist_model(stripe_dispute) if Fabric.config.persist?(:dispute)
      end

      def persist_model(stripe_dispute)
        dispute = retrieve_local(:dispute, stripe_dispute.id)
        return unless dispute

        dispute.sync_with(stripe_dispute)
        saved = dispute.save
        Fabric.config.logger.info "ChargeDisputeUpdated: Updated dispute: "\
          "#{dispute.stripe_id} saved: #{saved}"
      end
    end
  end
end
