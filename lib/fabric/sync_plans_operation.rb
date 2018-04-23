module Fabric
  class SyncPlansOperation
    include Fabric

    def call
      Fabric.config.logger.info "SyncPlansOperation: Fetching all plans and "\
        "syncing with any local copies."
      plan_list = Stripe::Plan.list(limit: 100)

      # iterate over list and continue pulling all plans
      stripe_plans = []
      stripe_plans.push(*plan_list)
      while plan_list.has_more?
        plan_list = plan_list.next_page
        stripe_plans.push(*plan_list)
      end

      stripe_plans.each do |p|
        plan = Fabric::Plan.find_by(stripe_id: p.id) || Fabric::Plan.new
        plan.sync_with(p)
        plan.save
      end
    end
  end
end
