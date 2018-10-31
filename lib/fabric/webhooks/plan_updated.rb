module Fabric
  module Webhooks
    class PlanUpdated
      include Fabric::Webhook

      def call(event)
        check_idempotency(event) or return if Fabric.config.store_events
        stripe_plan = Stripe::Plan.retrieve(event['data']['object']['id'])
        handle(event, stripe_plan)
        persist_model(stripe_plan) if Fabric.config.persist?(:plan)
      end

      def persist_model(stripe_plan)
        plan = retrieve_local(:plan, stripe_plan.id)
        return unless plan

        plan.sync_with(stripe_plan)
        saved = plan.save
        Fabric.config.logger.info "PlanUpdated: Updated plan: "\
          "#{plan.stripe_id} saved: #{saved}"
      end
    end
  end
end
