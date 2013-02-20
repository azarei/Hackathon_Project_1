require 'twitter/json_stream'
module Api
  # Start helper to create listener for twitter feed
  # Example:
  #  twitter_stream_capture = Api::TweetStremHelper.new
  #  twitter_stream_capture.start_twitter_stream_listener("Skyfall")

  class TweetStream
    def analyse_tweet(text)
      if (text["coordinates"])
        require_relative '../tools/sentiment-analyser/analyser'
        analyser = Analyser.new
        sentiment = analyser.analyse(text).sentiment

        # store coordinates + sentiment
        puts text["coordinates"]
        puts sentiment
      end
    end

    def start_twitter_stream_listener(trackEvent)
      @trackEvent = trackEvent
      EventMachine::run {
        trackEvent = trackEvent + "\#"
        stream = Twitter::JSONStream.connect(
          :path    => '/1/statuses/filter.json',
          :auth    => 'gettyhackathon:Pas$word1',
          :method  => 'POST',
          :content => "track=#{@trackEvent}"
        )

        stream.each_item do |item|
          require 'json'
          tweet = JSON.load(item)
          next if tweet["user"]["lang"] != "en"
          analyse_tweet(tweet)
        end

        stream.on_error do |message|
          $stdout.print "error: #{message}\n"
          $stdout.flush
          #email admin
        end

        stream.on_reconnect do |timeout, retries|
          $stdout.print "reconnecting in: #{timeout} seconds\n"
          $stdout.flush
        end

        stream.on_max_reconnects do |timeout, retries|
          $stdout.print "Failed after #{retries} failed reconnects\n"
          $stdout.flush
        end

        trap('TERM') {  
          stream.stop
          EventMachine.stop if EventMachine.reactor_running? 
        }
      }
      puts "The event loop has ended"
    end
  end
end
