module Versionist
  class NewPresenterGenerator < Rails::Generators::NamedBase
    source_root File.expand_path('../templates', __FILE__)

    argument :version, :type => :string

    def new_presenter
      template 'new_presenter.rb', File.join("app", "presenters", "#{version.underscore}", "#{file_name}_presenter.rb")
    end
  end
end
