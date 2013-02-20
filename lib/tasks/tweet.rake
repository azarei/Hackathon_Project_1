require 'api/tweet_stream2'

namespace :tweet do
  desc "Stream tweets for a given movie and store and calculate a sentiment rating"
  task :record, :title do |t, args|
    stream_helper = Api::TweetStremHelper.new
    stream_helper.start_twitter_stream_listener args.title
  end
end
