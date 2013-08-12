class Api::V3::FoosController < ApplicationController
  def index
    render :text => "v3"
  end
end
