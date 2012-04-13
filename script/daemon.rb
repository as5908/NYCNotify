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

class Authorization < ActiveRecord::Base
end
class User < ActiveRecord::Base
end
class Metric < ActiveRecord::Base
end

authorizations = Authorization.where(:provider =>"twitter")

TWITTER_KEY = ENV['TWITTER_KEY']
TWITTER_SECRET = ENV['TWITTER_SECRET']
WORDS_FILTER = ENV['WORDS'].split(",")
USER_TOKEN = ENV['USER_TOKEN']
USER_SECRET = ENV['USER_SECRET']
SCREEN_NAME = ENV['SCREEN_NAME']

def authenticate(oauth_token,oauth_secret)
 Twitter.configure do |config|
   config.consumer_key = TWITTER_KEY
   config.consumer_secret = TWITTER_SECRET
   config.oauth_token = oauth_token
   config.oauth_token_secret = oauth_secret
 end
end

def isTweetable (sid,uid)
  if !sid.nil? && Twitter.status(sid)["in_reply_to_user_id"].nil? && Twitter.status(sid)["retweeted_status"].nil? 
   return true
  end
  return false
end

def time_diff_milli(start, finish)
   return ((finish - start) * 1000.0)
end

TweetStream.configure do |config|
  config.consumer_key = TWITTER_KEY
  config.consumer_secret = TWITTER_SECRET
  config.oauth_token = USER_TOKEN
  config.oauth_token_secret = USER_SECRET
end

client = TweetStream::Client.new

client.on_error do |message|
  puts message
end
twitterId = Twitter.user(SCREEN_NAME).id.to_i
client.follow(twitterId) do |status|
  if isTweetable(status.id,status.user.id)
   failCount = 0
   retweetCount =0
   receiversCount = 0
   allFollowers = []
   accounts = []
   t1 = Time.now
   begin
   if WORDS_FILTER.any? { |w| status.text.downcase =~ /#{w}/ }
    authorizations.each do |authorization|
     oauth_token = authorization.token
     oauth_secret = authorization.secret
     auid = authorization.uid.to_i
     authenticate(oauth_token,oauth_secret)
     if status.user.id.to_s != auid.to_s #if authorized user is different from the one who posted the tweet
	 begin
    	  Twitter.retweet(status.id);
	  accounts = accounts.push(auid)
	  allFollowers = allFollowers | Twitter.follower_ids['ids'] #taking union af all followers
	  retweetCount = retweetCount + 1;

	 rescue Twitter::Error::Unauthorized #if access is revoked from twitter
	  puts "Unauthorized Exception occured"
	  failCount = failCount +1; 
	  user = User.find(authorization.user_id)
	  user.delete
	  authorization.delete
	 rescue Exception=>e #if any other kind of error
	   failCount = failCount +1;
	   puts "Unknown Exception occured"
	   puts e 
	   #catch the exception, do nothing and proceed
	 end       #end of begin
     end #end of if
   end #end of do |authorization|
  begin
    if status[:retweeted_status].nil? && status[:in_reply_to_user_id].nil?
	 t2 = Time.now
	 time = time_diff_milli(t1,t2)
	 amplified = allFollowers | accounts
	 receiversCount = amplified.size
	 metric = Metric.new :Status_id=> status.id, :Text=>status.text, :Accounts_Used => retweetCount, :Followers_Count=>receiversCount, :Time=>time_diff_milli(t1,t2), :Failures=> failCount
 	 metric.save
    end
    rescue Exception => e  #Exception related to database
    puts e.message  
    puts e.backtrace.inspect  
  end 
 end #end of if any? { |w| status =~ /#{w}/ } 
 rescue Exception=>e #any kind of exception e.g if status is deleted immediately after posting
  puts e   
 end
 end #end of if isTweetable
end
