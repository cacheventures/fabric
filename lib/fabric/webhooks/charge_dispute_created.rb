module Fabric
  module Webhooks
    class ChargeDisputeCreated
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
        charge = retrieve_local(:charge, stripe_dispute.charge)
        return unless charge

        dispute = Fabric::Dispute.new(charge: charge)
        dispute.sync_with(stripe_dispute)
        saved = dispute.save
        Fabric.config.logger.info "ChargeDisputeCreated: Created dispute: "\
          "#{dispute.stripe_id} saved: #{saved}"
      end
    end
  end
end
