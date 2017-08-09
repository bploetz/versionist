class V1::FoosController < ApplicationController
  def index
    respond_to do |format|
      format.text { render :text => "v1" }
      format.json { render :json => "v1" }
      format.xml { render :xml => "v1" }
    end
  end
end
