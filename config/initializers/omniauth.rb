Rails.application.config.middleware.use OmniAuth::Builder do
  provider :facebook, "309307029125402", "0d003a771a906dbdf39853500e23b2dc",:scope => 'email,offline_access,read_stream', :display => 'popup'
  #provider :twitter, "0b59udjJPemBKkCtPgrlg", "N2TroqsYV9o9o0UjRXPie2gYCv2sgrxfZonlbHHKamI",:scope => 'email,offline_access,read_stream', :display => 'popup'
  provider :twitter, TWITTER_KEY, TWITTER_SECRET
end
