require 'yard'
require 'fileutils'

module Versionist
  class CopyApiVersionGenerator < Rails::Generators::Base
    include InflectorFixes

    desc "copies an existing API version a new API version"

    source_root File.expand_path('../templates', __FILE__)

    argument :old_version, :type => :string
    argument :old_module_name, :type => :string
    argument :new_version, :type => :string
    argument :new_module_name, :type => :string

    def validate_old_version
      in_root do
        api_version_block = /api_version.*:module\s*(=>|:)\s*("|')#{module_name_for_route(old_module_name)}("|').*do/
        matching_version_blocks = File.readlines("config/routes.rb").grep(api_version_block)
        raise "old API version #{old_module_name} not found in config/routes.rb" if matching_version_blocks.empty?
        raise "old API version module namespace #{old_module_name} not found in app/controllers" if !File.exists?("app/controllers/#{module_name_for_path(old_module_name)}")
        raise "old API version module namespace #{old_module_name} not found in app/presenters" if !File.exists?("app/presenters/#{module_name_for_path(old_module_name)}")
        case Versionist.configuration.configured_test_framework
        when :test_unit
          raise "old API version module namespace #{old_module_name} not found in test/functional/#{module_name_for_path(old_module_name)}" if !File.exists?("test/functional/#{module_name_for_path(old_module_name)}")
          raise "old API version module namespace #{old_module_name} not found in test/presenters/#{module_name_for_path(old_module_name)}" if !File.exists?("test/presenters/#{module_name_for_path(old_module_name)}")
        when :rspec
          raise "old API version module namespace #{old_module_name} not found in spec/controllers/#{module_name_for_path(old_module_name)}" if !File.exists?("spec/controllers/#{module_name_for_path(old_module_name)}")
          raise "old API version module namespace #{old_module_name} not found in spec/presenters/#{module_name_for_path(old_module_name)}" if !File.exists?("spec/presenters/#{module_name_for_path(old_module_name)}")
        end
        raise "old API version #{old_version} not found in public/docs" if !File.exists?("public/docs/#{old_version}")
      end
    end

    def copy_routes
      in_root do
        if RUBY_VERSION =~ /1.8/ || RUBY_ENGINE != "ruby"
          log "ERROR: Cannot copy routes as this feature relies on the Ripper library, which is only available in MRI 1.9. You are running #{RUBY_ENGINE} #{RUBY_VERSION}."
          return
        end
        parser = YARD::Parser::SourceParser.parse_string(File.read("config/routes.rb"))
        existing_routes = nil
        parser.enumerator.first.traverse do |node|
          existing_routes = node.source if node.type == :fcall && node.source =~ /api_version.*:module\s*(=>|:)\s*("|')#{module_name_for_route(old_module_name)}("|')/
        end
        copied_routes = String.new(existing_routes)
        copied_routes.gsub!(/"#{module_name_for_route(old_module_name)}"/, "\"#{module_name_for_route(new_module_name)}\"")
        copied_routes.gsub!(/#{old_version}/, new_version)
        route copied_routes
      end
    end

    def copy_controllers
      in_root do
        log "Copying all files from app/controllers/#{module_name_for_path(old_module_name)} to app/controllers/#{module_name_for_path(new_module_name)}"
        FileUtils.cp_r "app/controllers/#{module_name_for_path(old_module_name)}", "app/controllers/#{module_name_for_path(new_module_name)}"
        Dir.glob("app/controllers/#{module_name_for_path(new_module_name)}/*.rb").each do |f|
          text = File.read(f)
          File.open(f, 'w') {|f| f << text.gsub(/#{old_module_name}/, new_module_name)}
        end
      end
    end

    # due to the inflector quirks we can't use hook_for :test_framework
    def copy_controller_tests
      in_root do
        case Versionist.configuration.configured_test_framework
        when :test_unit
          log "Copying all files from test/functional/#{module_name_for_path(old_module_name)} to test/functional/#{module_name_for_path(new_module_name)}"
          FileUtils.cp_r "test/functional/#{module_name_for_path(old_module_name)}", "test/functional/#{module_name_for_path(new_module_name)}"
          Dir.glob("test/functional/#{module_name_for_path(new_module_name)}/*.rb").each do |f|
            text = File.read(f)
            File.open(f, 'w') {|f| f << text.gsub(/#{old_module_name}/, new_module_name)}
          end
        when :rspec
          log "Copying all files from spec/controllers/#{module_name_for_path(old_module_name)} to spec/controllers/#{module_name_for_path(new_module_name)}"
          FileUtils.cp_r "spec/controllers/#{module_name_for_path(old_module_name)}", "spec/controllers/#{module_name_for_path(new_module_name)}"
          Dir.glob("spec/controllers/#{module_name_for_path(new_module_name)}/*.rb").each do |f|
            text = File.read(f)
            File.open(f, 'w') {|f| f << text.gsub(/#{old_module_name}/, new_module_name)}
          end
        else
          say "Unsupported test_framework: #{Versionist.configuration.configured_test_framework}"
        end
      end
    end

    def copy_presenters
      in_root do
        log "Copying all files from app/presenters/#{module_name_for_path(old_module_name)} to app/presenters/#{module_name_for_path(new_module_name)}"
        FileUtils.cp_r "app/presenters/#{module_name_for_path(old_module_name)}", "app/presenters/#{module_name_for_path(new_module_name)}"
        Dir.glob("app/presenters/#{module_name_for_path(new_module_name)}/*.rb").each do |f|
          text = File.read(f)
          File.open(f, 'w') {|f| f << text.gsub(/#{old_module_name}/, new_module_name)}
        end
      end
    end

    def copy_presenter_tests
      in_root do
        case Versionist.configuration.configured_test_framework
        when :test_unit
          log "Copying all files from test/presenters/#{module_name_for_path(old_module_name)} to test/presenters/#{module_name_for_path(new_module_name)}"
          FileUtils.cp_r "test/presenters/#{module_name_for_path(old_module_name)}", "test/presenters/#{module_name_for_path(new_module_name)}"
          Dir.glob("test/presenters/#{module_name_for_path(new_module_name)}/*.rb").each do |f|
            text = File.read(f)
            File.open(f, 'w') {|f| f << text.gsub(/#{old_module_name}/, new_module_name)}
          end
        when :rspec
          log "Copying all files from spec/presenters/#{module_name_for_path(old_module_name)} to spec/presenters/#{module_name_for_path(new_module_name)}"
          FileUtils.cp_r "spec/presenters/#{module_name_for_path(old_module_name)}", "spec/presenters/#{module_name_for_path(new_module_name)}"
          Dir.glob("spec/presenters/#{module_name_for_path(new_module_name)}/*.rb").each do |f|
            text = File.read(f)
            File.open(f, 'w') {|f| f << text.gsub(/#{old_module_name}/, new_module_name)}
          end
        else
          say "Unsupported test_framework: #{Versionist.configuration.configured_test_framework}"
        end
      end
    end

    def copy_documentation
      in_root do
        log "Copying all files from public/docs/#{old_version} to public/docs/#{new_version}"
        FileUtils.cp_r "public/docs/#{old_version}", "public/docs/#{new_version}"
        Dir.glob("public/docs/#{new_version}/*.html").each do |f|
          text = File.read(f)
          File.open(f, 'w') {|f| f << text.gsub(/#{old_version}/, new_version)}
        end
      end
    end
  end
end
