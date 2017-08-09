class Api::V3::BarsController < ApplicationController
  def index
    respond_to do |format|
      format.text { render :text => "v3" }
      format.json { render :json => "v3" }
      format.xml { render :xml => "v3" }
    end
  end
end
