module Fabric
  module Webhooks
    class PlanDeleted
      include Fabric::Webhook

      def call(event)
        check_idempotency(event) or return if Fabric.config.store_events
        persist_model(event) if Fabric.config.persist?(:plan)
        handle(event)
      end

      def persist_model(event)
        plan = retrieve_local(:plan, event.data.object.id)
        return unless plan

        plan.destroy
        Fabric.config.logger.info "PlanDeleted: Destroyed plan: "\
          "#{plan.stripe_id}"
      end

    end
  end
end
