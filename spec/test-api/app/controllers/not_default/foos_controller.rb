class NotDefault::FoosController < ApplicationController
  def index
    respond_to do |format|
      format.text { render text: "not_default" }
      format.json { render json: "not_default" }
      format.xml { render xml: "not_default" }
    end
  end
end
