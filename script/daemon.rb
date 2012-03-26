require 'yajl'
require 'tweetstream'
require 'twitter'
require 'rubygems'
require 'active_record'
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
class Metric < ActiveRecord::Base
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
  if !sid.nil? && Twitter.status(sid)["in_reply_to_user_id"].nil? && Twitter.status(sid)["retweeted_status"].nil? && uid.to_s != auid.to_s
   #puts "true"
   return true
  end
   #puts "false"
  return false
end

def time_diff_milli(start, finish)
   return ((finish - start) * 1000.0)
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
  failCount = 0;
  retweetCount =0;
  receiversCount = 0;
  t1 = Time.now
  #puts status.inspect
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
	 receiversCount = receiversCount + Twitter.follower_ids['ids'].size 
	 retweetCount = retweetCount + 1;
	 puts "#{status.id}-#{status.text}-#{retweetCount}-#{receiversCount}-0-#{failCount}"
	rescue Twitter::Error::Unauthorized #if access is revoked from twitter
	 #puts "You have been deregistered"
	 failCount = failCount +1; 
	 user = User.find(authorization.user_id)
	 user.delete
	 authorization.delete
	end
        
    end

end
if status[:retweeted_status].nil? && status[:in_reply_to_user_id].nil?
	t2 = Time.now
	time = time_diff_milli(t1,t2)
	#puts status.inspect
	#puts status[:retweeted_status].inspect
	#puts status[:text]
	#puts "#{status.id}-#{status.text}-#{retweetCount}-#{receiversCount}-#{time}-#{failCount}-DONE!!!"
	metric = Metric.new :Status_id=> status.id, :Text=>status.text, :Accounts_Used => retweetCount, :Followers_Count=>receiversCount, :Time=>time_diff_milli(t1,t2), :Failures=> failCount
 	metric.save
end
 #metric = Metric.new :Tweet_id=> status.id, :Tweet_text=>status.text, :Number_of_retweets => retweetCount, :Receivers=>receiversCount, :time=>time_diff_milli(t1,t2), :Failed_attempts=> failCount
 #metric.save
  #puts "#{status.text}"
end
