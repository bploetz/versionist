class V2::FoosController < ApplicationController
  def index
    respond_to do |format|
      format.text { render :text => "v2" }
      format.json { render :json => "v2" }
      format.xml { render :xml => "v2" }
    end
  end
end
