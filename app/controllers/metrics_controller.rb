class MetricsController < ApplicationController
  http_basic_authenticate_with :name => USERNAME, :password => PASSWORD
  helper_method :sort_column, :sort_direction
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
    @metrics = Metric.search(params[:search]).order('"'+sort_column + '"'+" " + sort_direction).paginate(:page=>params[:page], :per_page=>perPage)
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

  def sort_column
    Metric.column_names.include?(params[:sort]) ? params[:sort] : "created_at"
  end
  
  def sort_direction
    %w[asc desc].include?(params[:direction]) ? params[:direction] : "desc"
  end
end
