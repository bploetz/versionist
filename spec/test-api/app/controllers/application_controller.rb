class ApplicationController < ActionController::Base
  def not_found
    # just silence it
    head :not_found
  end
end
