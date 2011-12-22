module V2
  class FoosController < ActionController::Base
    def index
      render :text => "v2"
    end
  end
end
