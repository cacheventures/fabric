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
        unless plan.present?
          Fabric.config.logger.info 'PlanUpdated: No matching plan.'
          return
        end
        plan.sync_with(event.data.object)
        saved = plan.save
        Fabric.config.logger.info "PlanUpdated: Updated plan: "\
          "#{plan.stripe_id} saved: #{saved}"
      end

    end
  end
end
