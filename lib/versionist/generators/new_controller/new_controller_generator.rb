module Versionist
  class NewControllerGenerator < Rails::Generators::NamedBase
    source_root File.expand_path('../templates', __FILE__)

    argument :version, :type => :string

    def new_controller
      template 'new_controller.rb', File.join("app", "controllers", "#{version.underscore}", "#{file_name}_controller.rb")

      in_root do
        routes_block = /\.routes\.draw do/
        api_version_block = "scope :module => \"#{version.underscore}\" do"
        new_route = "resources :#{file_name}"
        if !File.readlines("config/routes.rb").grep(/#{api_version_block}/).any?
          new_route = "\n  #{api_version_block}\n    #{new_route}\n  end"
          inject_into_file "config/routes.rb", new_route, {:after => routes_block, :verbose => false}
        else
          inject_into_file "config/routes.rb", "\n    #{new_route}", {:after => api_version_block, :verbose => false}
        end
      end
    end
  end
end
