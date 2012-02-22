module Versionist
  class NewControllerGenerator < Rails::Generators::NamedBase
    desc "creates a new controller for an existing API version"
    source_root File.expand_path('../templates', __FILE__)

    argument :module_name, :type => :string

    def new_controller
      in_root do
        raise "API module namespace #{module_name} doesn't exist. Please run \'rails generate versionist:new_api_version\' generator first" if !File.exists?("app/controllers/#{module_name.underscore}")
        template 'new_controller.rb', File.join("app", "controllers", "#{module_name.underscore}", "#{file_name}_controller.rb")

        api_version_block = /api_version.*:module\s*(=>|:)\s*("|')#{module_name.gsub(/_{1}/, "__")}("|').*do/
        new_route = "    resources :#{file_name}\n"
        matching_version_blocks = File.readlines("config/routes.rb").grep(api_version_block)
        if matching_version_blocks.empty?
          raise "API version doesn't exist in config/routes.rb. Please run \'rails generate versionist:new_api_version\' generator first"
        elsif matching_version_blocks.size > 1
          raise "API version is duplicated in config/routes.rb"
        else
          version_block = matching_version_blocks.first
          inject_into_file "config/routes.rb", "#{new_route}", {:after => version_block, :verbose => false}
        end
      end
    end
  end
end
