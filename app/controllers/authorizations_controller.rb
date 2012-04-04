class AuthorizationsController < ApplicationController
  # GET /authorizations
  # GET /authorizations.json
  $auth_hash = {}
  def callback
    $auth_hash = request.env['omniauth.auth']
    redirect_to "/welcome"
  end
  
  def show
    if $auth_hash.empty?
       redirect_to "/failure"
    else
      @authorization = Authorization.find_by_provider_and_uid($auth_hash["provider"], $auth_hash["uid"])
      if @authorization
        oauth_token = $auth_hash['credentials']['token']
        oauth_secret = $auth_hash['credentials']['secret']
        authenticate oauth_token, oauth_secret
        @msg = "Welcome back #{@authorization.user.name}! You have already signed up." 
        @user = @authorization.user
      else
        user = User.new :name => $auth_hash["info"]["name"], :nickname => $auth_hash["info"]["nickname"]
        user.authorizations.build :provider => $auth_hash["provider"], :uid => $auth_hash["uid"], :token => $auth_hash['credentials']['token'], 
        :secret => $auth_hash['credentials']['secret']
        user.save
        @msg = "Hi #{user.name}! Thank you for registering." 
        @user = user
      end
    end
    $auth_hash = {}
  end

  #gain authorization using twitter token and secret
  def authenticate (oauth_token, oauth_secret)
    Twitter.configure do |config|
      config.consumer_key = TWITTER_KEY
      config.consumer_secret = TWITTER_SECRET
      config.oauth_token = "#{oauth_token}"
      config.oauth_token_secret = "#{oauth_secret}"
    end
  end
	
  def error
    render :text=>"You are not authorized to view this page"
  end  

  def failure
    
  end
end
