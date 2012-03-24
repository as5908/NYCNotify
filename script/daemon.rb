require 'yajl'
require 'tweetstream'
require 'twitter'
require 'rubygems'
require 'active_record'

#require 'activerecord'
require 'uri'

db = URI.parse(ENV['DATABASE_URL'] || 'postgres://localhost/dbdevelopment')

ActiveRecord::Base.establish_connection(
  :adapter  => db.scheme == 'postgres' ? 'postgresql' : db.scheme,
  :host     => db.host,
  :username => db.user,
  :password => db.password,
  :database => db.path[1..-1],
  :encoding => 'utf8'
)

#ActiveRecord::Base.establish_connection(
#  :adapter=>"postgresql",
#  :database => "db/development",
#  :host=>"localhost",
#  :username => "postgres",
#  :password => "root",
#)

class Authorization < ActiveRecord::Base
end
class User < ActiveRecord::Base
end

authorizations = Authorization.where(:provider =>"twitter")

TWITTER_KEY = '0b59udjJPemBKkCtPgrlg'
TWITTER_SECRET = 'N2TroqsYV9o9o0UjRXPie2gYCv2sgrxfZonlbHHKamI'

def authenticate(oauth_token,oauth_secret)
 Twitter.configure do |config|
   config.consumer_key = TWITTER_KEY
   config.consumer_secret = TWITTER_SECRET
   #config.oauth_token = "517995479-IKRTBBsTu3RTa0KkZR1qRInyoUlE8vEdERDeTWyK"
   #config.oauth_token_secret = "rK59NTqH9TUjCNXL03QDqzpvjTU5r5OSog5ms9syjk"
   config.oauth_token = oauth_token
   config.oauth_token_secret = oauth_secret
 end
end

def isTweetable (sid,uid,auid)
  #puts "retweet status is :"
  #puts Twitter.status(sid).inspect
  if !sid.nil? && Twitter.status(sid)["retweeted_status"].nil? && uid.to_s != auid.to_s
   #puts "true"
   return true
  end
   #puts "false"
  return false
end

TweetStream.configure do |config|
  config.consumer_key = TWITTER_KEY
  config.consumer_secret = TWITTER_SECRET
  config.oauth_token = "237290525-7xnf8Vxh0DeS4JX3qAp06cQV7ny4xca3gpaaU7Bu"
  config.oauth_token_secret = "VgJUPP3sNHmmQvYd2qIpESB0cbCESELT9aWetbSvGQ"
  #config.auth_method = :oauth
  #config.parser   = :yajl
end

client = TweetStream::Client.new

client.on_error do |message|
  puts message
end


client.follow(237290525,16145875) do |status|
  authorizations.each do |authorization|
    oauth_token = authorization.token
    oauth_secret = authorization.secret
    auid = authorization.uid.to_i
    #puts "authenticating...#{auid} and #{status.user.id} ...status id is #{status.id}"
    authenticate(oauth_token,oauth_secret)
    if isTweetable(status.id,status.user.id,auid)
	#puts "retweeting..."
	begin
    	 Twitter.retweet(status.id);
	rescue Twitter::Error::Unauthorized #if access is revoked from twitter
	 puts "You have been deregistered" 
	 user = User.find(authorization.user_id)
	 user.delete
	 authorization.delete
	end
    end
  end
  
  puts "#{status.text}"
end
