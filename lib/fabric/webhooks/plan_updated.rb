module Fabric
  module Webhooks
    class PlanUpdated
      include Fabric::Webhook

      def call(event)
        check_idempotency(event) or return if Fabric.config.store_events
        persist_model(event) if Fabric.config.persist?(:plan)
        handle(event)
      end

      def persist_model(event)
        stripe_plan = event.data.object
        plan = retrieve_local(:plan, stripe_plan.id)
        return unless plan
        return unless most_recent_update?(plan, event)

        plan.sync_with(stripe_plan)
        saved = plan.save
        Fabric.config.logger.info "PlanUpdated: Updated plan: "\
          "#{plan.stripe_id} saved: #{saved}"
      end
    end
  end
end
