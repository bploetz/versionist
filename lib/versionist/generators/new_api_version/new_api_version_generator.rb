module Versionist
  class NewApiVersionGenerator < Rails::Generators::NamedBase
    source_root File.expand_path('../templates', __FILE__)

    def new_api_version
      empty_directory "app/controllers/#{file_name}"
      template 'base_controller.rb', File.join("app", "controllers", "#{file_name}", "base_controller.rb")
      empty_directory "app/presenters/#{file_name}"
    end
  end
end
