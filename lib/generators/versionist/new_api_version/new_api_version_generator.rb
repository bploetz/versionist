module Versionist
  class NewApiVersionGenerator < Rails::Generators::Base
    include InflectorFixes

    desc "creates the infrastructure for a new API version"

    source_root File.expand_path('../templates', __FILE__)

    argument :version, :type => :string
    argument :module_name, :type => :string
    argument :versioning_strategy, :banner => "VERSIONING_STRATEGY_OPTIONS", :type => :hash

    def add_routes
      in_root do
        api_version_block = /api_version.*:module\s*(=>|:)\s*("|')#{module_name_for_route(module_name)}("|')/
        matching_version_blocks = File.readlines("config/routes.rb").grep(api_version_block)
        raise "API version already exists in config/routes.rb" if !matching_version_blocks.empty?
        versioning_strategy.symbolize_keys!
        route "api_version(:module => \"#{module_name_for_route(module_name)}\", #{versioning_strategy.to_s.gsub(/[\{\}]/, '')}) do\n  end"
      end
    end

    def add_controller_base
      in_root do
        empty_directory "app/controllers/#{module_name_for_path(module_name)}"
        template 'base_controller.rb', File.join("app", "controllers", "#{module_name_for_path(module_name)}", "base_controller.rb")
      end
    end

    # due to the inflector quirks we can't use hook_for :test_framework
    def add_controller_base_tests
      in_root do
        case Versionist.configuration.configured_test_framework
        when :test_unit
          empty_directory "test/functional/#{module_name_for_path(module_name)}"
          template 'base_controller_functional_test.rb', File.join("test", "functional", "#{module_name_for_path(module_name)}", "base_controller_test.rb")
          empty_directory "test/integration/#{module_name_for_path(module_name)}"
          template 'base_controller_integration_test.rb', File.join("test", "integration", "#{module_name_for_path(module_name)}", "base_controller_test.rb")
        when :rspec
          empty_directory "spec/controllers/#{module_name_for_path(module_name)}"
          template 'base_controller_spec.rb', File.join("spec", "controllers", "#{module_name_for_path(module_name)}", "base_controller_spec.rb")
          empty_directory "spec/requests/#{module_name_for_path(module_name)}"
          template 'base_controller_spec.rb', File.join("spec", "requests", "#{module_name_for_path(module_name)}", "base_controller_spec.rb")
        else
          say "Unsupported test_framework: #{Versionist.configuration.configured_test_framework}"
        end
      end
    end

    def add_presenters_base
      in_root do
        empty_directory "app/presenters/#{module_name_for_path(module_name)}"
        template 'base_presenter.rb', File.join("app", "presenters", "#{module_name_for_path(module_name)}", "base_presenter.rb")
      end
    end

    def add_presenter_test
      in_root do
        case Versionist.configuration.configured_test_framework
        when :test_unit
          empty_directory "test/presenters/#{module_name_for_path(module_name)}"
          template 'base_presenter_test.rb', File.join("test", "presenters", "#{module_name_for_path(module_name)}", "base_presenter_test.rb")
        when :rspec
          empty_directory "spec/presenters/#{module_name_for_path(module_name)}"
          template 'base_presenter_spec.rb', File.join("spec", "presenters", "#{module_name_for_path(module_name)}", "base_presenter_spec.rb")
        else
          say "Unsupported test_framework: #{Versionist.configuration.configured_test_framework}"
        end
      end
    end

    def add_documentation_base
      in_root do
        empty_directory "public/docs/#{version}"
        template 'docs_index.rb', File.join("public", "docs", "#{version}", "index.html")
        template 'docs_style.rb', File.join("public", "docs", "#{version}", "style.css")
      end
    end
  end
end
