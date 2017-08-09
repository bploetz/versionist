class V11::FoosController < ApplicationController
  def index
    respond_to do |format|
      format.text { render text: "v11" }
      format.json { render json: "v11" }
      format.xml { render xml: "v11" }
    end
  end
end
