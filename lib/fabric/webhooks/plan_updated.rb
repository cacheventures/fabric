module Fabric
  module Webhooks
    class PlanUpdated
      include Fabric::Webhook

      def call(event)
        id = event['data']['object']['id']
        return PriceUpdated.new.call(event) if id.starts_with?('price_')

        check_idempotence(event) or return if Fabric.config.store_events

        stripe_plan = retrieve_resource('plan', id)
        return if stripe_plan.nil?

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
