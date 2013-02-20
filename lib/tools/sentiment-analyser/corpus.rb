require "#{File.dirname(__FILE__)}/document"

class Corpus

  def initialize name
    require 'redis'
    $redis = Redis.new
    @name = name
  end

  def entry_count
    $redis.get "learning:#{@name}:total-count"
  end

  def add document
    document.each_token do |token|
      $redis.incr "learning:#{@name}:#{token}"
      $redis.incr "learning:#{@name}:total-count"
    end
  end

  def load_from_directory directory
    Dir.glob("#{File.dirname(__FILE__)}/#{directory}/*.txt") do |entry|
      IO.foreach(entry) do |line|
        add Document.new(line)
      end
    end
  end

  def token_count token
    count = $redis.get "learning:#{@name}:#{token}"
    return count unless count.nil?
    0
  end
end
