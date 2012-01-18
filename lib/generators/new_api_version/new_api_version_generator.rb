module Versionist
  class NewApiVersionGenerator < Rails::Generators::NamedBase
    source_root File.expand_path('../templates', __FILE__)

    def new_api_version
      empty_directory "app/controllers/#{file_name}"
      template 'base_controller.rb', File.join("app", "controllers", "#{file_name}", "base_controller.rb")
      empty_directory "app/presenters/#{file_name}"
      empty_directory "public/docs/#{file_name}"
      template 'docs_index.rb', File.join("public", "docs", "#{file_name}", "index.html")
      template 'docs_style.rb', File.join("public", "docs", "#{file_name}", "style.css")
    end
  end
end
