module Fabric
  class PlanPolicy
    include Fabric

    def initialize(customer)
      @customer = get_document(Fabric::Customer, customer)
    end

    def plan
      @customer.plan || default_plan
    end

  end
end
