require 'rubygems'
require 'twitter'
require 'net/http'
require 'uri'

module Api
  class Tweet
    def initialize
      @client = Twitter::Client.new(
        :consumer_key => "tpJxiHlK9imuVng7Ssr1g",
        :consumer_secret => "uzVKqjht7z1Qv0FB927ApOoGMLr8OXkA7HAC8aKRuQM",
        :oauth_token => "990067262-f2hMmNKJ97aR2xMAwCkF9QLkrIxtcvrG69rsOU0Q",
        :oauth_token_secret => "CuMBg43NMgnsICNXfYAsLlVhbNskGLFL7D8hGBFZ8"
      )
    end

    def trends
      current_trends = []
      @client.trends.each do |trend|
        current_trends << trend.name
      end

      return current_trends
    end

    def search(phrase, onlyGeo = true)
      @statuses = []
      @untilDate = Date.today
      begin 
        @client.search(phrase, :count => 100, :geocode => '40.7142,74.0064,150000mi', :until => (@untilDate).to_s(:db), :lang => 'en', :result_type => "mixed").results.map do |status|
          if (onlyGeo) 
            if (status.geo)
              tweet = {
                'id' => status.id,
                'created_at' => status.created_at,
                'from' => status.from_user,
                'text' => status.text,
                'coordinates' => status.geo.coordinates
              }
              @statuses << tweet
            else
              #skip it
            end
          else
            tweet = {
              'id' => status.id,
              'created_at' => status.created_at,
              'from' => status.from_user,
              'text' => status.text,
              'coordinates' => status.geo.coordinates
            }
            @statuses << tweet
          end
        end
        @untilDate -= 1.days
      end while @statuses.size < 10
      return @statuses
    end
  end
end
