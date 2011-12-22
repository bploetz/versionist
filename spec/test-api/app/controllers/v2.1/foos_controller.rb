module V2_1
  class FoosController < ActionController::Base
    def index
      render :text => "v2.1"
    end
  end
end
