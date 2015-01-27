require 'twitter'
require 'sinatra'

set :server, 'webrick'

get '/' do
  erb :index
end

post '/results' do

  parser = Parser.new(params)

  @identities = parser.identities
  @topics = parser.topics
  @tweets = parser.tweets
  @topic_results = parser.topic_results

  erb :results

end

class Parser
  
  attr_accessor(:identities, :topics) 

  def initialize(params)

    @identities = params[:identities]
    @topics = params[:topics]

    @client = Twitter::REST::Client.new do |config|
      config.consumer_key        = ENV['CONSUMER_KEY']
      config.consumer_secret     = ENV['CONSUMER_SECRET']
      config.access_token        = ENV['ACCESS_TOKEN']
      config.access_token_secret = ENV['ACCESS_TOKEN_SECRET']
    end
  end

  def tweets
    @identities.split(", ").map do |screen_name|
      @client.user_timeline("#{screen_name}", :count => 200).map do |tweet|
        {"#{screen_name}" => tweet.to_h[:text]}
      end
    end
  end

  # def topic_count
  #   @topic_count = []
  #    @topics.split(", ").each do |topic|
  #     tweets.each do |el| 
  #       el.each do |el| 
  #         topic_count << el.count if el.each{|el| el.include?("#{topic}")}
  #       end
  #     end
  #   end
  #   return @topic_count
  # end

  def topic_results
    @results = []
    @topics.split(", ").each do |topic|
      tweets.each do |el| 
        el.each do |el| 
          el.each do |k,v| 
            @results << "#{k}=> #{v}\n" if v.include?("#{topic}") 
          end
        end
      end
    end
    return @results
  end

end