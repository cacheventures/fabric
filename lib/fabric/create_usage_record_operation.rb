module Fabric
  class CreateUsageRecordOperation
    include Fabric

    def initialize(customer, attributes = {})
      Fabric.config.logger.info "CreateUsageRecordOperation: Started with "\
        "#{customer} #{attributes}"
      @customer = get_document(Fabric::Customer, customer)
      @attributes = attributes
    end

    def call
      stripe_record = Stripe::UsageRecord.create(@attributes)
      usage_record = @customer.usage_records.build
      usage_record.sync_with(stripe_record)
      saved = usage_record.save
      Fabric.config.logger.info "CreateUsageRecordOperation: Completed. "\
        "saved: #{saved}"
      usage_record
    end
  end
end
