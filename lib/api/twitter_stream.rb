require 'eventmachine'
require 'em-http'
require 'json'
require 'oauth'
require 'oauth/client/em_http'

CONSUMER_KEY = "tpJxiHlK9imuVng7Ssr1g" 
CONSUMER_SECRET = "uzVKqjht7z1Qv0FB927ApOoGMLr8OXkA7HAC8aKRuQM" 
ACCESS_TOKEN = "990067262-f2hMmNKJ97aR2xMAwCkF9QLkrIxtcvrG69rsOU0Q" 
ACCESS_TOKEN_SECRET = "CuMBg43NMgnsICNXfYAsLlVhbNskGLFL7D8hGBFZ8"

def twitter_oauth_consumer
  @twitter_oauth_consumer ||= OAuth::Consumer.new(CONSUMER_KEY, CONSUMER_SECRET, :site => "http://twitter.com")
end 

def twitter_oauth_access_token
  @twitter_oauth_access_token ||= OAuth::AccessToken.new(twitter_oauth_consumer, ACCESS_TOKEN, ACCESS_TOKEN_SECRET)
end

EventMachine.run do
  toFollow=[twitter_id1, twitter_id2]
  http = EventMachine::HttpRequest.new(
    'http://stream.twitter.com/1/statuses/filter.json'
  ).post(:body=>{"follow"=>toFollow.join(",")},
    :head => {"Content-Type" => "application/x-www-form-urlencoded"},
    :timeout => -1) do |client|
    twitter_oauth_consumer.sign!(client, twitter_oauth_access_token)
    end

  buffer = ""

  http.stream do |chunk|
    buffer += chunk
    while line = buffer.slice!(/.+\r?\n/)
      puts "handling a new event:"+line
    end
  end
  http.errback { puts "Error" }
  http.disconnect { puts "Lost Connection" }
end

