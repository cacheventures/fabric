require 'stripe'
require 'stripe_event'
require 'enumerize'
require 'mongoid'
require 'env_helper'
require 'sidekiq'

require 'fabric/logger'
require 'fabric/errors'
require 'fabric/attach_payment_method_operation'
require 'fabric/detach_payment_method_operation'
require 'fabric/billing_policy'
require 'fabric/cancel_subscription_operation'
require 'fabric/create_card_for_subscription_operation'
require 'fabric/create_card_operation'
require 'fabric/create_charge_operation'
require 'fabric/create_coupon_operation'
require 'fabric/create_customer_operation'
require 'fabric/create_invoice_operation'
require 'fabric/create_invoice_item_operation'
require 'fabric/create_subscription_operation'
require 'fabric/create_usage_record_operation'
require 'fabric/create_setup_intent_operation'
require 'fabric/delete_coupon_operation'
require 'fabric/pay_invoice_operation'
require 'fabric/plan_policy'
require 'fabric/resume_subscription_operation'
require 'fabric/sync_coupons_operation'
require 'fabric/sync_plans_operation'
require 'fabric/update_card_operation'
require 'fabric/update_coupon_operation'
require 'fabric/update_customer_operation'
require 'fabric/update_payment_method_operation'
require 'fabric/update_plan_operation'
require 'fabric/update_subscription_operation'
require 'fabric/version'
require 'fabric/webhook'
require 'fabric/webhooks/charge_created'
require 'fabric/webhooks/charge_updated'
require 'fabric/webhooks/charge_captured'
require 'fabric/webhooks/charge_expired'
require 'fabric/webhooks/charge_failed'
require 'fabric/webhooks/charge_pending'
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
require 'fabric/webhooks/invoice_deleted'
require 'fabric/webhooks/invoice_item_updated'
require 'fabric/webhooks/invoice_updated'
require 'fabric/webhooks/invoice_payment_failed'
require 'fabric/webhooks/invoice_payment_succeeded'
require 'fabric/webhooks/payment_intent_updated'
require 'fabric/webhooks/payment_intent_amount_capturable_updated'
require 'fabric/webhooks/payment_intent_payment_failed'
require 'fabric/webhooks/payment_intent_succeeded'
require 'fabric/webhooks/payment_method_attached'
require 'fabric/webhooks/payment_method_detached'
require 'fabric/webhooks/payment_method_updated'
require 'fabric/webhooks/payment_method_card_automatically_updated'
require 'fabric/webhooks/plan_created'
require 'fabric/webhooks/plan_deleted'
require 'fabric/webhooks/plan_updated'
require 'fabric/webhooks/setup_intent_created'
require 'fabric/webhooks/setup_intent_updated'
require 'fabric/webhooks/setup_intent_setup_failed'
require 'fabric/webhooks/setup_intent_succeeded'
require 'fabric/webhooks/source_created'
require 'fabric/webhooks/source_deleted'
require 'fabric/webhooks/source_updated'
require 'fabric/webhooks/source_expiring'
require 'fabric/webhooks/subscription_created'
require 'fabric/webhooks/subscription_deleted'
require 'fabric/webhooks/subscription_updated'
require 'fabric/webhooks/plan_updated'
require 'fabric/app/workers/worker.rb'
require 'fabric/app/workers/webhook_worker.rb'

module Fabric
  autoload :Card, 'fabric/app/models/fabric/card'
  autoload :Charge, 'fabric/app/models/fabric/charge'
  autoload :Coupon, 'fabric/app/models/fabric/coupon'
  autoload :Customer, 'fabric/app/models/fabric/customer'
  autoload :Event, 'fabric/app/models/fabric/event'
  autoload :Invoice, 'fabric/app/models/fabric/invoice'
  autoload :InvoiceItem, 'fabric/app/models/fabric/invoice_item'
  autoload :PaymentIntent, 'fabric/app/models/fabric/payment_intent'
  autoload :PaymentMethod, 'fabric/app/models/fabric/payment_method'
  autoload :Plan, 'fabric/app/models/fabric/plan'
  autoload :SetupIntent, 'fabric/app/models/fabric/setup_intent'
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
    attr_accessor :persist_models

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

  def sync_and_save_subscription_and_items(subscription, stripe_subscription)
    subscription.sync_with(stripe_subscription)
    sub_items = subscription.subscription_items

    item_ids = sub_items.map(&:stripe_id)
    stripe_item_ids = stripe_subscription.items.data.map(&:id)
    removed_item_ids = item_ids - stripe_item_ids

    sub_items.where(:stripe_id.in => removed_item_ids).destroy_all
    stripe_subscription.items.data.each do |sub_item|
      item = sub_items.find_by(stripe_id: sub_item.id) || sub_items.build
      item.sync_with(sub_item)
      item.save
    end

    subscription.save
  end

  def convert_metadata(hash)
    nh = {}
    hash.each do |k, v|
      if v.to_i.to_s == v
        nh[k] = v.to_i
        next
      end
      if v.to_f.to_s == v
        nh[k] = v.to_f
        next
      end
      if v.in? %w[true false]
        nh[k] = v == 'true' ? true : false
        next
      end

      nh[k] = v
    end
    nh
  end

  def flogger
    Fabric.config.logger
  end

end
