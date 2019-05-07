# fabric

![fabric](/images/white_and_blue_stripes_by_apeculiarpersonage_d63d4ut-fullview.jpg?raw=true "blue striped fabric")

By [Cache Ventures](https://cacheventures.com)

[![Build Status](https://travis-ci.com/cacheventures/fabric.svg?branch=master)](https://travis-ci.com/cacheventures/fabric)
[![Maintainability](https://api.codeclimate.com/v1/badges/a99a88d28ad37a79dbf6/maintainability)](https://codeclimate.com/github/cacheventures/fabric/maintainability)

Fabric is an opinionated Ruby framework for developers, making it easier to integrate a Rails app with [Stripe](https://stripe.com).

## Requirements

Fabric assumes you're using MongoDB with the Mongoid ODM. It also uses Sidekiq for asynchronous job processing. (Another job processing library could conceivably be used, but you would need to reimplement Fabric::Worker; there is more information on how Fabric::Worker works below.) Webhooks work best with [stripe_event](https://github.com/integrallis/stripe_event).

It supports Stripe API version 2018-02-28. There are plans to support future API versions as patches, but this is a work in progress.

## Overview

Fabric came about because we had already integrated Stripe into other applications of ours, but we had encountered issues with the ad-hoc approach we'd been taking. We decided on a more structured approach to the integration, with some inviolable principles to guide things.

### Represent the state of Stripe

The main principle of Fabric is mirroring the data in Stripe as closely as possible. This means that before data is saved locally, it must have already been updated remotely. It also means that you don't add any fields that aren't stored by Stripe. (If any application-specific data needs to be included, it must be set on Stripe's metadata field, so that it can be set on the Stripe object, too.) An exception is made for associations here, since Fabric::Customer models will need to have a database association with a User or Account model, for instance.

The intended benefit of this philosophy is that your application can confidently check the state of customers' billing information at any time without having to worry if the data is stale or in an incorrect state.

### Operations can be reused

In order to encapsulate the multiple lines of code that can be required to perform operations against the Stripe API (for example, updating a customer requires retrieving it first), a series of Operation classes were created. They all are initialized with all necessary data, and will then execute when their `#call` method is called.

As a matter of necessity, application specific code will find itself in operations. The rule here would be to create base-level operations which can then be reused by higher-level operations. For example, we have a CreateSubscriptionOperation. If you wanted to modify it to also associate the subscription with another model in your system, you could create an operation called CreateSubscriptionAndAssociateOperation and call that instead. That operation would then call CreateSubscriptionOperation internally, and it would update the association after it had completed.

This is also used internally. For example, the CreateCardForSubscription operation combines a CreateCardOperation and a CreateSubscriptionOperation.

The intended benefit of this is that updates to base level code (for bugs, Stripe API upgrades, etc.) will not require updating the same code in multiple places.

### Don't update state of other models based on what happens in Stripe

Instead of creating an ad-hoc system of fields stored on your application's own models in order to store billing state, your application should query Stripe directly. To accomplish this, there are a few Policy classes included, which can be updated with application specific code.

For example: you may want to display a page only to users who have an active subscription. Instead of creating a field on your User model called `subscribed` and updating it when you create or delete subscriptions, as well as when you get webhooks in, you should prefer querying the state of the Fabric::Subscription model directly. The BillingPolicy class can be used to minimize code repetition here. So, you might instead write `redirect_to root_url unless Fabric::BillingPolicy.new(@user.customer).billing?`.

The intended benefit of this is that you needn't concern yourself with the messy game of trying to update and maintain state separately from Stripe. This can only lead to issues, especially in the case of bugs that cause issues with state which are impossible to trace. In a worst case scenario, if your code just queries against the state of data in Stripe, if your local data is inconsistent, you could just delete everything you have locally and retrieve it again from Stripe. This also means that you can confidently look in Stripe at the state of things and know that this state is what is reflected in your application. This philosophy drives your application into a proactive state of checking local models which represent Stripe data instead of reactively updating things when webhooks come in and when you make API calls.

### Operations have first-class asynchronous support

The parameters passed to an Operation when it is initialized should be able to be serialized to Redis for easy asynchronous operation. This is the purpose of the `Fabric.get_document` method. It enables either synchronous calling, passing in a Mongoid model instance directly, or asynchronous calling, passing in the document's id and retrieving it from the database at initialization.

This will enable all Operations to be called asynchronously with Sidekiq and Fabric::Worker. This improves the user experience of the site, allowing things to happen in the background if they can, and preventing the web process from being tied up waiting for Stripe API calls to complete.

## What's included

### Models

Fabric includes many models which reflect their corresponding Stripe models. It does not include every model in Stripe, simply because our integrations haven't required it. Contributions adding more models in a manner compatible with our current methodology as outlined above are welcome.

The models all have a `sync_with` method. This method is a convenience method for setting all the local model's fields to what they currently are on Stripe. They accept a single parameter: an instance of the corresponding Stripe object. `#sync_with` is called from Operations, and optionally from Webhooks. Ideally, these are the only places where it should be used.

There are some other embellishments on models. For example, look at [Fabric::Subscription](/lib/fabric/app/models/fabric/subscription.rb). We've added a few scopes to make querying easier. Another example is [Fabric::Coupon](/lib/fabric/app/models/fabric/coupon.rb). We've added a `#usable?` method here to check the expiration date and maximum redemptions of a cookie. Things like this could have easily been placed somewhere else, but in the few instances where their domain is only the Fabric model itself, we've added them directly to the models. There are not a lot of these.

We've also added validations as best we could to represent the restrictions enforced by Stripe. Ideally, it shouldn't come to this, since all models should only be created once a remote primary exists to sync from. They are, however, there to check for mistakes.

### Operations

Fabric includes a non-comprehensive set of operations, the existence of which is tailored to code our applications have needed. (Similarly to Models, the addition of more base level operations in a manner compatible with our current methodology is welcome.) We have, of course, removed any which have application specific code inside of them.

The general structure of an Operation is:

1. Retrieve the remote object(s) from Stripe (if necessary)
2. Perform all required creations, updates, and/or deletes
3. Update local Fabric documents, using `#sync_with`, as necessary.

As mentioned above, higher level Operations that reuse lower level operations are encouraged as a means to add application specific code, such as associating Users and Fabric::Customers.

#### Asynchronous Usage

Operations can be used asynchronously via Fabric::Worker. Fabric::Worker can be called with the snake cased name of the operation, without the word "operation" at the end; this will be constantized and then called with the rest of the arguments passed to Fabric::Worker. For example,

```ruby
Fabric::Worker.perform_async(
  'create_card',
  @customer.id.to_s,
  @form.token
)
```

would be equivalent to its synchronous alternative, `CreateCardOperation.new(@customer, @form.token).call`.

You can configure a Proc to call at the completion of each webhook. This is configurable with the `Fabric.config.worker_callback` option. This will get called with `:success` or `:error`, indicating whether or not the code completed without raising an exception. In the case of an exception, a message will be passed as a message parameter. This feature was intended to be used with ActionCable to send updates to the user's browser. However, by making it a Proc, we hoped to leave it more open ended and implementation agnostic. An example of a working ActionCable callback is below:

```ruby
Fabric.configure do |config|
  config.worker_callback = proc do |data, type, message|
    type_str = type.to_s
    data[type_str]['args']['type'] = type_str
    data[type_str]['args']['message'] = message if message.present?
    ActionCable.server.broadcast(
      data[type_str]['channel'],
      data[type_str]['args']
    )
  end
end
```

In the above example, `data` would be a hash passed into Fabric::Worker as the last argument, which, containing a key/value `hash['callback'] => true`, would be removed before the Operation class was called and instead passed through to the worker_callback Proc as the first argument. See [Fabric::Worker](/lib/fabric/app/workers/worker.rb).

### Policies

A BillingPolicy class and PlanPolicy class have been included. They contain a few examples which may be useful to you. More importantly, they show the intended way that application code will use Fabric models to implement business logic.

In a full integration, more methods will need to be added to BillingPolicy at the least. Additional Policy classes may also need to be created.

### Webhooks

Fabric also contains a system of dealing with Stripe webhooks. Using [stripe_event](https://github.com/integrallis/stripe_event), our Webhook classes, which all have empty initializers and implement all of their logic in their `#call` methods, can be used to subscribe to webhooks.

```ruby
StripeEvent.configure do |events|
  events.subscribe 'customer.subscription.created',
    Fabric::Webhooks::SubscriptionCreated.new
  # ...
end
```

#### Asynchronous usage

In order to make this asynchronous, you can use a Fabric::WebhookWorker to accomplish the same thing. For example:

```ruby
events.subscribe 'customer.created' do |event|
  Fabric::WebhookWorker.perform(event.to_hash, 'plan_deleted')
end
```

#### Events

When a webhook is received, Fabric optionally supports storing a Fabric::Event model (corresponding with Stripe's Event) which can be stored. This is a minimal version of the event which does not contain the full contents of the webhook. Instead, it only stores the event id, webhook type, customer id, and api version, with the first 3 fields defining a unique event. This uniqueness is then used to check idempotence of events coming in from Stripe, ensuring you don't run your webhook code twice for the same event, even if Stripe sends it twice. If `Fabric.config.store_events` is set to `true` (the default), Fabric will perform these checks. This is implemented in all webhooks in the project using the `check_idempotence` method.

#### Webhooks use remote resources

Using the data on the webhook to create or update models can lead to issues, because Stripe webhooks can come in out of order. This means that a `customer.subscription.updated` webhook that reflects an update that occurred at 12:50 PM could be sent after an update that occurred at 12:51 PM. In order to minimize the risk that this can cause, we never use the data on the webhook to update local models. Instead, we retrieve the associated remote resource and sync our local model with that. This way, even if webhooks arrive out of order, the local model will be updated to have the latest data from Stripe.

#### Handle method

After idempotence checking and remote resource retrieval, in each webhook, you can define any application specific logic in a `handle` method. This can be done by opening up the class and overriding our stub `handle` method. This is documented in [Fabric::Webhook#handle](/lib/fabric/webhook.rb).

#### Persist models

Any updates to local models from webhooks in Fabric are performed in the `persist_model` method. This can be entirely disabled by the `Fabric.config.persist_models` config setting.

### Helper Methods

The [Fabric](/lib/fabric/fabric.rb) and [Fabric::Webook](/lib/fabric/webhook.rb) modules contain some convenience/helper methods which are useful inside of Fabric code. Check out the modules for more details. Many of these are already used inside the project.

## Configuration Options

You can set global configuration options with `Fabric.configure`:

```ruby
Fabric.configure do |c|
  c.store_events = false
  c.persist_models = :all
  c.logger = Rails.logger
  # c.persist_models = %i[charge coupon customer]
end
```

The options are:

* `store_events`: A Boolean value determining whether or not Webhook handlers will store a Fabric::Event model for each incoming webhook and check the database upon receipt of incoming webhooks, skipping any further webhook code if the event already exists. Defaults to `true`.
* `logger`: A logger class to use. Defaults to an `ActiveSupport::Logger` instance to STDOUT. This should probably be set to `Rails::Logger` in a Rails app.
* `worker_callback`: A Proc which is called by Fabric::Worker upon completion of the Operation, only if Fabric::Worker was also passed a Hash with a key/value `hash['callback'] => true`. Defaults to an empty Proc.
* `persist_models`: Which models / API resources the `persist_model` method is called for upon execution of Webhook code. Accepts either an array of symbols containing API resource names, e.g. `%i(charge coupon customer)`, or the symbol `:all`, which enables it for all resources. Passing an empty array will disable all `persist_model` methods and will run all Webhook event checking code and `handle` methods without creating, updating, or destroying local models based on webhooks. (This is not recommended, unless you're implementing that in `handle`.) Defaults to `:all`.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
