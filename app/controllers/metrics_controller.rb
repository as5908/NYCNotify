class MetricsController < ApplicationController
  http_basic_authenticate_with :name => USERNAME, :password => PASSWORD
  # GET /metrics
  # GET /metrics.json
  def show
    @title= "Metrics"
    perPage = 20;
    if params[:page].present?
     @count = (params[:page].to_i-1) * perPage
    else
     @count= 0
    end
    @metrics = Metric.find(:all, :order => "created_at DESC").paginate(:page=>params[:page], :per_page=>perPage)
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @metrics }
    end
  end
		
  def json
   @title= "JSON formatted data"
   @metrics = Metric.find(:all, :order => "created_at DESC")
   #render :text => @users.inspect
   #@json = JSON.generate(@users)
   #render :text => "hi"
   render :json=> @metrics.to_json
  end

  def index
   @metrics = Metric.find(:all, :order => "created_at DESC")
    respond_to do |format|
      format.html # index.html.erb
      format.csv  # index.csv.erb
    end
  end
end
