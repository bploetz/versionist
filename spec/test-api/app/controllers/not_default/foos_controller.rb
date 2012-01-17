class NotDefault::FoosController < ApplicationController
  def index
    render :text => "not_default"
  end
end
