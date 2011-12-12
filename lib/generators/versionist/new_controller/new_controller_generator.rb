module Versionist
  class NewControllerGenerator < Rails::Generators::NamedBase
    source_root File.expand_path('../templates', __FILE__)

    argument :version, :type => :string

    def new_controller
      template 'new_controller.rb', File.join("app", "controllers", "#{version.underscore}", "#{file_name}_controller.rb")
    end
  end
end
