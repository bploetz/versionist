# versionist

[![Build Status](https://secure.travis-ci.org/bploetz/versionist.png?branch=master)](http://travis-ci.org/bploetz/versionist)

A plugin for versioning Rails 3 based RESTful APIs. Versionist supports three versioning strategies out of the box:

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

Add the following dependency to your Rails 3 application's `Gemfile` file and run `bundle install`:

    gem 'versionist'


## Configuration

Versionist provides the method `api_version` that you use in your Rails 3 application's `config/routes.rb` file to constrain a collection of routes to a specific version of your API.
The versioning strategy used by the collection of routes constrained by `api_version` is set by specifying either `:header`, `:path`, or `:parameter` (and their supporting values)
in the configuration Hash passed to `api_version`. You configure the module namespace for your API version by specifying `:module` in the configuration Hash passed to `api_version`.

## Version/Module Naming Convention Gotcha

Note that if your public facing version naming convention uses dots (i.e. v1.2.3), your module names cannot use dots, as you obviously cannot use dots in module names in Ruby.
If you wish to simply replace dots with underscores, you'll need to use *two* underscores (i.e. `__`) in the module name passed to `api_version` to work around a quirk in Rails' inflector.

For example, if your public facing version is v2.0.0 and you want to map this to the module `V2_0_0`, you would do the following in `api_routes`:

    api_version(:module => "V2__0__0", :header => "Accept", :value => "application/vnd.mycompany.com-v2.0.0") do
      ...
    end

If you use the generators provided Versionist (more below) simply pass the module name as is (without this double underscore hack) and Versionist will take care of this detail for you.

    rails generate versionist:new_api_version v2.0.0 V2_0_0 header:Accept value:application/vnd.mycompany.com-v2.0.0
      route  api_version(:module => "V2__0__0", :header=>"Accept", :value=>"application/vnd.mycompany.com-v2.0.0") do
      end
      create  app/controllers/v2_0_0
      create  app/controllers/v2_0_0/base_controller.rb
      create  spec/controllers/v2_0_0
      create  spec/controllers/v2_0_0/base_controller_spec.rb
      create  app/presenters/v2_0_0
      create  app/presenters/v2_0_0/base_presenter.rb
      create  spec/presenters/v2_0_0
      create  spec/presenters/v2_0_0/base_presenter_spec.rb
      create  public/docs/v2.0.0
      create  public/docs/v2.0.0/index.html
      create  public/docs/v2.0.0/style.css


    rails generate versionist:new_controller foos V2_0_0
      create  app/controllers/v2_0_0/foos_controller.rb
      create  spec/controllers/v2_0_0/foos_controller_spec.rb


    rails generate versionist:new_presenter foos V2_0_0
      create  app/presenters/v2_0_0/foos_presenter.rb
      create  spec/presenters/v2_0_0/foos_presenter_spec.rb


Don't shoot the messenger. :-)


## Versioning Strategies

### HTTP Header

This strategy uses an HTTP header to request a specific version of your API.

    Accept: application/vnd.mycompany.com-v1,application/json
    GET /foos

You configure the header to be inspected and the header value specifying the version in the configuration Hash passed to `api_version`.

Examples:

#### Content negotiation via the `Accept` header:

    MyApi::Application.routes.draw do
      api_version(:module => "V1", :header => "Accept", :value => "application/vnd.mycompany.com-v1") do
        match '/foos.(:format)' => 'foos#index', :via => :get
        match '/foos_no_format' => 'foos#index', :via => :get
        resources :bars
      end
    end

`Accept` Header Gotcha

Please note: when your routes do not include an explicit format in the URL (i.e. `match 'foos.(:format)' => foos#index`), Rails inspects the `Accept` header to determine the requested format. Since
an `Accept` header can have multiple values, Rails uses the *first* one present to determine the format. If your custom version header happens to be the first value in the `Accept` header, Rails would 
incorrectly try to interpret it as the format. If you use the `Accept` header, Versionist will move your custom version header (if found) to the end of the `Accept` header so as to not interfere with
Rails' format resolution logic. This is the only case where Versionist will alter the incoming request.


#### Custom header:

    MyApi::Application.routes.draw do
      api_version(:module => "V20120317", :header => "X-CUSTOM-HEADER", :value => "v20120317") do
        match '/foos.(:format)' => 'foos#index', :via => :get
        match '/foos_no_format' => 'foos#index', :via => :get
        resources :bars
      end
    end


### Path

This strategy uses a URL path prefix to request a specific version of your API.

    GET /v3.5.1/foos

You configure the path version prefix to be applied to the routes.

Example:

    MyApi::Application.routes.draw do
      api_version(:module => "V3__5__1", :path => "/v3.5.1") do
        match '/foos.(:format)' => 'foos#index', :via => :get
        match '/foos_no_format' => 'foos#index', :via => :get
        resources :bars
      end
    end


### Request Parameter

This strategy uses a request parameter to request a specific version of your API.

    GET /foos?version=v1.1.3

You configure the parameter name and value to be applied to the routes.

Example:

    MyApi::Application.routes.draw do
      api_version(:module => "V1__1__3", :parameter => "version", :value => "v1.1.3") do
        match '/foos.(:format)' => 'foos#index', :via => :get
        match '/foos_no_format' => 'foos#index', :via => :get
        resources :bars
      end
    end


### Default Version

If a request is made to your API without specifying a specific version, by default a RoutingError (i.e. 404) will occur. You can optionally configure Versionist to
return a specific version by default when none is specified. To specify that a version should be used as the default, include `:default => true` in the config hash
passed to the `api_version` method.

Example.

    MyApi::Application.routes.draw do
      api_version(:module => "V20120317", :header => "X-CUSTOM-HEADER", :value => "v20120317", :default => true) do
        match '/foos.(:format)' => 'foos#index', :via => :get
        match '/foos_no_format' => 'foos#index', :via => :get
        resources :bars
      end
    end

If you attempt to specify more than one default version, an error will be thrown at startup.


## Generators

Versionist comes with generators to facilitate creating new versions of your APIs and new components with an existing version.
To see the available generators, simply run `rails generate`, and you will see the versionist generators under the `versionist` namespace.

The following generators are available:

`versionist:new_api_version` - creates the infrastructure for a new API version. This will create:

- A new controller namespace, base controller and test
- A new presenters namespace, base presenter and test
- A new documentation directory and base files

Usage

    rails generate versionist:new_api_version <version> <module namespace> <versioning strategy options>

Example:

    rails generate versionist:new_api_version v2.0.0 V2_0_0 header:Accept value:application/vnd.mycompany.com-v2.0.0
      route  api_version(:module => "V2__0__0", :header=>"Accept", :value=>"application/vnd.mycompany.com-v2.0.0") do
      end
      create  app/controllers/v2_0_0
      create  app/controllers/v2_0_0/base_controller.rb
      create  spec/controllers/v2_0_0
      create  spec/controllers/v2_0_0/base_controller_spec.rb
      create  app/presenters/v2_0_0
      create  app/presenters/v2_0_0/base_presenter.rb
      create  spec/presenters/v2_0_0
      create  spec/presenters/v2_0_0/base_presenter_spec.rb
      create  public/docs/v2.0.0
      create  public/docs/v2.0.0/index.html
      create  public/docs/v2.0.0/style.css


`versionist:new_controller` - creates a new controller class with the given name under the given version module.

Usage

    rails generate versionist:new_controller <name> <module namespace>

Example:

    rails generate versionist:new_controller foos V2_0_0
      create  app/controllers/v2_0_0/foos_controller.rb
      create  spec/controllers/v2_0_0/foos_controller_spec.rb


`versionist:new_presenter` - creates a new presenter class with the given name under the given version module.

Usage

    rails generate versionist:new_presenter <name> <module namespace>

Example:

    rails generate versionist:new_presenter foos V2_0_0
      create  app/presenters/v2_0_0/foos_presenter.rb
      create  spec/presenters/v2_0_0/foos_presenter_spec.rb
