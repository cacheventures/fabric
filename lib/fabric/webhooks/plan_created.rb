module Fabric
  module Webhooks
    class PlanCreated
      include Fabric::Webhook

      def call(event)
        if Fabric.config.store_events
          check_idempotency(event) or return
        end

        persist_model(event) if Fabric.config.persist?(:plan)

        handle(event)
      end

      def persist_model(event)
        plan = Fabric::Plan.new
        plan.sync_with(event.data.object)
        saved = plan.save
        Fabric.config.logger.info "PlanCreated: Created plan: "\
          "#{plan.stripe_id} saved: #{saved}"
      end

    end
  end
end
