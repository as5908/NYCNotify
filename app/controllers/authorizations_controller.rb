class AuthorizationsController < ApplicationController
  # GET /authorizations
  # GET /authorizations.json
  def callback
    auth_hash = request.env['omniauth.auth']
    @authorization = Authorization.find_by_provider_and_uid(auth_hash["provider"], auth_hash["uid"])
    if @authorization
      oauth_token = auth_hash['credentials']['token']
      oauth_secret = auth_hash['credentials']['secret']
      authenticate oauth_token, oauth_secret
      @msg = "Welcome back #{@authorization.user.name}! You have already signed up." 
      @user = @authorization.user
    else
      user = User.new :name => auth_hash["info"]["name"], :nickname => auth_hash["info"]["nickname"]
      user.authorizations.build :provider => auth_hash["provider"], :uid => auth_hash["uid"], :token => auth_hash['credentials']['token'], 
      :secret => auth_hash['credentials']['secret']
      user.save
      @msg = "Hi #{user.name}! Thank you for registering." 
      @user = user
    end
  end

  def deregister
    auth_hash = request.env['omniauth.auth']
    #render :text=> auth_hash.inspect
    @authorization = Authorization.find_by_provider_and_uid(auth_hash["provider"], auth_hash["uid"])
    if @authorization
      oauth_token = auth_hash['credentials']['token']
      oauth_secret = auth_hash['credentials']['secret']
      authenticate oauth_token, oauth_secret
      #Twitter.update("From my app")
      user_id = authorization.user_id
      user = User.find(user_id)
      user_name = user.name
      user.authorization.delete
      #authorization.delete
      @msg = "Hi #{user_name}! You have been deregistered." 
      @users = User.all
    else
      user = User.new :name => auth_hash["info"]["name"], :nickname => auth_hash["info"]["nickname"]
      @msg = "Hi #{user.name}! You are not registered." 
    end
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
  
  def failure
    
  end
end
