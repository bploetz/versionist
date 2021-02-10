# versionist

[![Build Status](https://travis-ci.org/bploetz/versionist.svg?branch=master)](https://travis-ci.org/bploetz/versionist)

A plugin for versioning Rails based RESTful APIs. Versionist supports three versioning strategies out of the box:

- Specifying version via an HTTP header
- Specifying version by prepending paths with a version slug
- Specifying version via a request parameter

A version of your API consists of:

- Namespaced controllers/routes
- Namespaced presenters
- Namespaced tests
- Documentation

Versionist includes Rails generators for generating new versions of your API as well as new components within an existing version.


## Installation

Add the following dependency to your Rails application's `Gemfile` file and run `bundle install`:

    gem 'versionist'


## Configuration

Versionist provides the method `api_version` that you use in your Rails application's `config/routes.rb` file to constrain a collection of routes to a specific version of your API.
The versioning strategies used by the collection of routes constrained by `api_version` is set by specifying `:header`, `:path`, and/or `:parameter` (and their supporting values)
in the configuration Hash passed to `api_version`. You configure the module namespace for your API version by specifying `:module` in the configuration Hash passed to `api_version`.

### Upgrading from Versionist 0.x to 1.x+

A backwards incompatible change was made to the format of the configuration hash passed to `api_version` starting in Versionist 1.0.
Prior to 1.0, `api_version` expected hashes with the following structure:

```ruby
api_version(:module => "V1", :header => "Accept", :value => "application/vnd.mycompany.com; version=1") do
  ...
end
```

In order to support multiple concurrent versioning strategies per api version, `api_version` expects that the `:header`, `:parameter`, and `:path`
keys point to hashes and contain the required keys.

```ruby
api_version(:module => "V1", :header => {:name => "Accept", :value => "application/vnd.mycompany.com; version=1"}) do
  ...
end

api_version(:module => "V1", :parameter => {:name => "version", :value => "1"}) do
  ...
end

api_version(:module => "V1", :path => {:value => "v1"}) do
  ...
end
```

An error will be thrown at startup if your `config/routes.rb` file contains 0.x style `api_version` entries when running with Versionist 1.x+.

## Versioning Strategies

### HTTP Header

This strategy uses an HTTP header to request a specific version of your API.

    Accept: application/vnd.mycompany.com; version=1,application/json
    GET /foos

You configure the header to be inspected and the header value specifying the version in the configuration Hash passed to `api_version`.

Examples:

##### Content negotiation via the `Accept` header:

```ruby
MyApi::Application.routes.draw do
  api_version(:module => "V1", :header => {:name => "Accept", :value => "application/vnd.mycompany.com; version=1"}) do
    match '/foos.(:format)' => 'foos#index', :via => :get
    match '/foos_no_format' => 'foos#index', :via => :get
    resources :bars
  end
end
```

`Accept` Header Gotcha

Please note: when your routes do not include an explicit format in the URL (i.e. `match 'foos.(:format)' => foos#index`), Rails inspects the `Accept` header to determine the requested format. Since
an `Accept` header can have multiple values, Rails uses the *first* one present to determine the format. If your custom version header happens to be the first value in the `Accept` header, Rails would 
incorrectly try to interpret it as the format. If you use the `Accept` header, Versionist will move your custom version header (if found) to the end of the `Accept` header so as to not interfere with
Rails' format resolution logic. This is the only case where Versionist will alter the incoming request.


##### Custom header:

```ruby
MyApi::Application.routes.draw do
  api_version(:module => "V20120317", :header => {:name => "Api-Version", :value => "v20120317"}) do
    match '/foos.(:format)' => 'foos#index', :via => :get
    match '/foos_no_format' => 'foos#index', :via => :get
    resources :bars
  end
end
```

### Path

This strategy uses a URL path prefix to request a specific version of your API.

    GET /v3/foos

You configure the path version prefix to be applied to the routes.

Example:

```ruby
MyApi::Application.routes.draw do
  api_version(:module => "V3", :path => {:value => "v3"}) do
    match '/foos.(:format)' => 'foos#index', :via => :get
    match '/foos_no_format' => 'foos#index', :via => :get
    resources :bars
  end
end
```

### Request Parameter

This strategy uses a request parameter to request a specific version of your API.

    GET /foos?version=v2

You configure the parameter name and value to be applied to the routes.

Example:

```ruby
MyApi::Application.routes.draw do
  api_version(:module => "V2", :parameter => {:name => "version", :value => "v2"}) do
    match '/foos.(:format)' => 'foos#index', :via => :get
    match '/foos_no_format' => 'foos#index', :via => :get
    resources :bars
  end
end
```

### Default Version

If a request is made to your API without specifying a specific version, by default a RoutingError (i.e. 404) will occur. You can optionally configure Versionist to
return a specific version by default when none is specified. To specify that a version should be used as the default, include `:default => true` in the config hash
passed to the `api_version` method.

Example.

```ruby
MyApi::Application.routes.draw do
  api_version(:module => "V20120317", :header => {:name => "Api-Version", :value => "v20120317"}, :default => true) do
    match '/foos.(:format)' => 'foos#index', :via => :get
    match '/foos_no_format' => 'foos#index', :via => :get
    resources :bars
  end
end
```

If you attempt to specify more than one default version, an error will be thrown at startup.

Note that when you configure a default API version, you will see the routes under your default version show up twice when running `rake routes`. This is due to the fact that Versionist adds another `scope` to your routes to handle the default case. Unfortunately `rake routes` does not show you enough contextual information to be able to differentiate the two, but this is the expected behavior.


### Rails Route :defaults Hash

The `api_version` method also supports Rails' [`:defaults`](http://guides.rubyonrails.org/routing.html#defining-defaults) hash (note that this is different than
the `:default` key which controls the default API version described above). If a `:defaults` hash is passed to `api_version`, it will be applied to the collection
of routes constrainted by `api_version`.

Example.

```ruby
MyApi::Application.routes.draw do
  api_version(:module => "V20120317", :header => {:name => "Api-Version", :value => "v20120317"}, :defaults => {:format => :json}, :default => true) do
    match '/foos.(:format)' => 'foos#index', :via => :get
    match '/foos_no_format' => 'foos#index', :via => :get
    resources :bars
  end
end
```

## Multiple Versioning Strategies Per API Version

An API version may optionally support multiple concurrent versioning strategies.

Example.
```ruby
MyApi::Application.routes.draw do
  api_version(:module => "V1", :header => {:name => "Accept", :value => "application/vnd.mycompany.com; version=1"}, :path => {:value => "v1"}) do
    match '/foos.(:format)' => 'foos#index', :via => :get
    match '/foos_no_format' => 'foos#index', :via => :get
    resources :bars
  end
end
```

## A Note About Testing

Rails functional tests (ActionController::TestCase) and RSpec Controller specs are for testing controller action methods in isolation.
They do not go through the full Rails stack, specifically the Rails dispatcher code path, which is where versionist hooks in to do its thing.

In order to test your versioned API routes, use integration tests (ActionDispatch::IntegrationTest) if you're using Test::Unit, or Request specs if you're using RSpec.

Test::Unit Example:
```ruby
# test/integration/v1/test_controller_test.rb
require 'test_helper'

class V1::TestControllerTest < ActionDispatch::IntegrationTest
  test "should get v1" do
    get '/test', {}, {'Accept' => 'application/vnd.mycompany.com; version=1'}
    assert_response 200
    assert_equal "v1", @response.body
  end
end
```

RSpec Example:
```ruby
# spec/requests/v1/test_controller_spec.rb
require 'spec_helper'

describe V1::TestController do
  it "should get v1" do
    get '/test', {}, {'Accept' => 'application/vnd.mycompany.com; version=1'}
    assert_response 200
    assert_equal "v1", response.body
  end
end
```

## Generators

Versionist comes with generators to facilitate managing the versions of your API. To see the available generators, simply run
`rails generate`, and you will see the versionist generators under the `versionist` namespace.

The following generators are available:

### `versionist:new_api_version`

creates the infrastructure for a new API version. This will create:

- A new controller namespace, base controller and test
- A new presenters namespace, base presenter and test
- A new documentation directory and base files

Usage

    rails generate versionist:new_api_version <version> <module namespace> [options]

Examples:

    # HTTP header versioning strategy
    rails generate versionist:new_api_version v2 V2 --header=name:Accept value:"application/vnd.mycompany.com; version=2"

    # request parameter versioning strategy
    rails generate versionist:new_api_version v2 V2 --parameter=name:version value:2

    # path versioning strategy
    rails generate versionist:new_api_version v2 V2 --path=value:v2

    # multiple versioning strategies
    rails generate versionist:new_api_version v2 V2 --header=name:Accept value:"application/vnd.mycompany.com; version=2" --parameter=name:version value:2

    # default version
    rails generate versionist:new_api_version v2 V2 --path=value:v2 --default

    # route :defaults hash
    rails generate versionist:new_api_version v2 V2 --path=value:v2 --defaults=format:json


    rails generate versionist:new_api_version v2 V2 --header=name:Accept value:"application/vnd.mycompany.com; version=2"
      route  api_version(:module => "V2", :header => {:name => "Accept", :value => "application/vnd.mycompany.com; version=2"}) do
      end
      create  app/controllers/v2
      create  app/controllers/v2/base_controller.rb
      create  spec/controllers/v2
      create  spec/controllers/v2/base_controller_spec.rb
      create  spec/requests/v2
      create  spec/requests/v2/base_controller_spec.rb
      create  app/presenters/v2
      create  app/presenters/v2/base_presenter.rb
      create  spec/presenters/v2
      create  spec/presenters/v2/base_presenter_spec.rb
      create  app/helpers/v2
      create  spec/helpers/v2
      create  public/docs/v2
      create  public/docs/v2/index.html
      create  public/docs/v2/style.css


### `versionist:new_controller`

creates a new controller class with the given name under the given version module.

Usage

    rails generate versionist:new_controller <name> <module namespace>

Example:

    rails generate versionist:new_controller foos V2
      create  app/controllers/v2/foos_controller.rb
      create  spec/controllers/v2/foos_controller_spec.rb
      create  spec/requests/v2/foos_controller_spec.rb


### `versionist:new_presenter`

creates a new presenter class with the given name under the given version module.

Usage

    rails generate versionist:new_presenter <name> <module namespace>

Example:

    rails generate versionist:new_presenter foos V2
      create  app/presenters/v2/foos_presenter.rb
      create  spec/presenters/v2/foos_presenter_spec.rb


### `versionist:copy_api_version`

copies an existing API version to a new API version. This will do the following:

- Copy all existing routes in config/routes.rb from the old API version to routes for the new API version in config/routes.rb (**see note below**)
- Copy all existing controllers and tests from the old API version to the new API version
- Copy all existing presenters and tests from the old API version to the new API version
- Copy all existing helpers and tests from the old API version to the new API version
- Copy all documentation from the old API version to the new API version

**Note**: routes can only be copied with MRI Ruby 1.9 and above, as this feature relies on Ripper which is only available 
in stdlib in MRI Ruby 1.9 and above. Outside of routes copying, the other copy steps will work just fine in Ruby 1.8 and other
non-MRI Ruby implementations.

Usage

    rails generate versionist:copy_api_version <old version> <old module namespace> <new version> <new module namespace>

Example:

    rails generate versionist:copy_api_version v2 V2 v3 V3
      route  api_version(:module => "V3", :header=>"Accept", :value=>"application/vnd.mycompany.com; version=3") do
      end
      Copying all files from app/controllers/v2 to app/controllers/v3
      Copying all files from spec/controllers/v2 to spec/controllers/v3
      Copying all files from app/presenters/v2 to app/presenters/v3
      Copying all files from spec/presenters/v2 to spec/presenters/v3
      Copying all files from app/helpers/v2 to app/helpers/v3
      Copying all files from spec/helpers/v2 to spec/helpers/v3
      Copying all files from public/docs/v2 to public/docs/v3

## Additional Resources
- [API Versioning using Versionist](http://www.multunus.com/blog/2014/04/api-versioning-using-versionist/)
