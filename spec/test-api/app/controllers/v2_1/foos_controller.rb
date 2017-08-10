class V2_1::FoosController < ApplicationController
  def index
    respond_to do |format|
      format.text { render :text => "v2.1" }
      format.json { render :json => "v2.1" }
      format.xml { render :xml => "v2.1" }
    end
  end
end
