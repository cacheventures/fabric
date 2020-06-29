# CHANGELOG

## Backwards Incompatible Changes

### Fabric::Card & Fabric::Source

* Cards are removed
* customer.source.* webhooks now only work for source objects. Card objects are ignored in webhooks.
* UpdateCardOperation is removed

### CreateSubscriptionOperation

* Change arguments to not include a customer, and instead have customer passed in through the attributes
* return [sub, stripe_sub] instead of just sub

### PlanPolicy

* removed

### Fabric.default_plan

* removed

### Fabric::Customer#plan

* removed

### Fabric::BillingPolicy#plan

* removed
