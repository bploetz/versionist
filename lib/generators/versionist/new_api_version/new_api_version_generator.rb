module Versionist
  class NewApiVersionGenerator < Rails::Generators::Base
    source_root File.expand_path('../templates', __FILE__)

    argument :version, :type => :string
    argument :module_name, :type => :string

    def new_api_version
      empty_directory "app/controllers/#{module_name.underscore}"
      template 'base_controller.rb', File.join("app", "controllers", "#{module_name.underscore}", "base_controller.rb")
      empty_directory "app/presenters/#{module_name.underscore}"
      empty_directory "public/docs/#{version}"
      template 'docs_index.rb', File.join("public", "docs", "#{version}", "index.html")
      template 'docs_style.rb', File.join("public", "docs", "#{version}", "style.css")
    end
  end
end
