module Fabric
  class CreateCustomerBalanceTransactionOperation
    include Fabric

    def initialize(customer, attributes = {})
      Fabric.config.logger.info "CreateCustomerBalanceTransactionOperation: "\
        "Started with #{customer} #{attributes}"
      @customer = get_document(Fabric::Customer, customer)
      @attributes = attributes
    end

    def call
      stripe_cbt = Stripe::Customer.create_balance_transaction(
        @customer.stripe_id,
        @attributes
      )
      cbt = Fabric::CustomerBalanceTransaction.new
      cbt.sync_with(stripe_cbt)
      cbt_saved = cbt.save
      
      stripe_customer = Stripe::Customer.retrieve(@customer.stripe_id)
      @customer.sync_with(stripe_customer)
      cust_saved = @customer.save

      Fabric.config.logger.info "CreateCustomerBalanceTransactionOperation: "\
        "Completed. cbt_saved: #{cbt_saved}, cust_saved: #{cust_saved}"
      [cbt, stripe_cbt]
    end
  end
end
