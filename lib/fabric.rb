require 'stripe'
require 'stripe_event'
require 'enumerize'
require 'mongoid'
require 'env_helper'
require 'sidekiq'

require 'fabric/billing_policy'
require 'fabric/cancel_subscription_operation'
require 'fabric/create_card_for_subscription_operation'
require 'fabric/create_card_operation'
require 'fabric/create_charge_operation'
require 'fabric/create_customer_operation'
require 'fabric/create_invoice_operation'
require 'fabric/create_invoice_item_operation'
require 'fabric/create_subscription_operation'
require 'fabric/create_usage_record_operation'
require 'fabric/plan_policy'
require 'fabric/resume_subscription_operation'
require 'fabric/sync_coupons_operation'
require 'fabric/sync_plans_operation'
require 'fabric/update_customer_operation'
require 'fabric/update_plan_operation'
require 'fabric/update_subscription_operation'
require 'fabric/version'
require 'fabric/webhook'
require 'fabric/webhooks/charge_failed'
require 'fabric/webhooks/charge_refunded'
require 'fabric/webhooks/charge_succeeded'
require 'fabric/webhooks/coupon_created'
require 'fabric/webhooks/coupon_deleted'
require 'fabric/webhooks/coupon_updated'
require 'fabric/webhooks/customer_updated'
require 'fabric/webhooks/discount_created'
require 'fabric/webhooks/discount_deleted'
require 'fabric/webhooks/discount_updated'
require 'fabric/webhooks/dispute_created'
require 'fabric/webhooks/invoice_created'
require 'fabric/webhooks/invoice_updated'
require 'fabric/webhooks/invoice_deleted'
require 'fabric/webhooks/payment_failed'
require 'fabric/webhooks/payment_succeeded'
require 'fabric/webhooks/plan_created'
require 'fabric/webhooks/plan_deleted'
require 'fabric/webhooks/plan_updated'
require 'fabric/webhooks/source_created'
require 'fabric/webhooks/source_updated'
require 'fabric/webhooks/source_deleted'
require 'fabric/webhooks/subscription_created'
require 'fabric/webhooks/subscription_deleted'
require 'fabric/webhooks/subscription_updated'
require 'fabric/webhooks/plan_updated'
require 'fabric/app/workers/worker.rb'

module Fabric
  autoload :Card, 'fabric/app/models/fabric/card'
  autoload :Charge, 'fabric/app/models/fabric/charge'
  autoload :Coupon, 'fabric/app/models/fabric/coupon'
  autoload :Customer, 'fabric/app/models/fabric/customer'
  autoload :Discount, 'fabric/app/models/fabric/discount'
  autoload :Event, 'fabric/app/models/fabric/event'
  autoload :Invoice, 'fabric/app/models/fabric/invoice'
  autoload :InvoiceItem, 'fabric/app/models/fabric/invoice_item'
  autoload :Plan, 'fabric/app/models/fabric/plan'
  autoload :Subscription, 'fabric/app/models/fabric/subscription'
  autoload :SubscriptionItem, 'fabric/app/models/fabric/subscription_item'
  autoload :UsageRecord, 'fabric/app/models/fabric/usage_record'

  class << self
    def config
      @config ||= Config.new
    end

    def configure
      yield config
    end
  end

  # define Config class, to be used as
  #   Fabric.configure do |c|
  #     c.store_events = false
  #     c.persist_models = :all
  #     # c.persist_models = %i[charge coupon customer]
  #   end
  class Config
    attr_accessor :store_events
    attr_accessor :logger
    attr_accessor :worker_callback

    def initialize
      @store_events = true
      @logger = ActiveSupport::Logger.new($stdout)
      @worker_callback = Proc.new {}
      @persist_models = :all
    end

    def persist?(document)
      @persist_models == :all || @persist_models[document].present?
    end
  end

  module_function

  def stripe_id_for(reference)
    if reference.is_a? Stripe::APIResource
      reference.id
    elsif reference.is_a? Mongoid::Document
      reference.stripe_id
    else
      fail InvalidResourceError, reference.to_s
    end
  end

  def default_plan
    default_plan_id = ENVHelper.get('fabric_default_plan')
    return Fabric::Plan.first unless default_plan_id.present?
    plan = Fabric::Plan.find_by(stripe_id: default_plan_id)
    plan.present? ? plan : Fabric::Plan.first
  end

  def get_document(klass, reference)
    if reference.is_a?(Mongoid::Document)
      reference
    else
      klass.unscoped.find(reference)
    end
  end

  class Error < StandardError; end
  class InvalidResourceError < Error; end
  class SubscriptionAlreadyExistsError < Error; end
end
