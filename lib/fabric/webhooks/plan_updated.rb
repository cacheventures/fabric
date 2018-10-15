module Fabric
  module Webhooks
    class PlanUpdated
      include Fabric::Webhook

      def call(event)
        if Fabric.config.store_events
          check_idempotency(event) or return
        end

        persist_model(event) if Fabric.config.persist?(:plan)

        handle(event)
      end

      def persist_model(event)
        plan = Fabric::Plan.find_by(stripe_id: event.data.object.id)
        if plan.present?
          plan.sync_with(event.data.object)
          saved = plan.save
          Fabric.config.logger.info "PlanUpdated: Updated plan: "\
            "#{plan.stripe_id} saved: #{saved}"
        else
          Fabric.config.logger.info 'PlanUpdated: No matching plan.'
        end
      end

    end
  end
end
