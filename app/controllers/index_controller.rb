class IndexController < ApplicationController
  require 'api/nyt.rb'
  require 'api/getty_connect.rb'
  require 'api/twitter.rb'
  #require 'api/twitter_stream.rb'
  require 'api/geocode.rb'

  def index
    api_helper = Api::Tweet.new
    @trends_list = api_helper.trends 
  end

  def test
    #@twt = Api::Tweet.new
    #@twts = @twt.search('christmas', true)
    #@twts = @twt.trends()
    
    #@nyt = Api::NYT.new
    #@twts = @nyt.get_geocode('calgary')

    @geo = Api::Geo.new
    @twts = @geo.encode('38.703378,-78.541259')
  
    #@gc = Api::GettyConnect.new
    #@twts = @gc.search_image('Cats', 2)
  
    respond_to do |format|
      format.html # show.html.erb
      format.json { render :json => @twts.to_json }
    end
    #@ts = Api::TwitStream.new
    #@twts = @ts.getData 
  end

  def image
    if (params[:phrase])
      phrase = params[:phrase]
    else
      phrase = 'Apple'
    end
    if (params[:num])
      num = params[:num]
    else
      num = 10
    end
    if (params[:long] && params[:lat])
      coord_string = params[:lat]+","+params[:long]
       res=Geokit::Geocoders::GoogleGeocoder.reverse_geocode coord_string
       if (res.city)
         city = res.city
       else 
         city = ''
       end
    else
      city = ''
    end

    @gc = Api::GettyConnect.new
    @images = @gc.search_image(phrase+' '+city, num.to_i)

    respond_to do |format|
      format.json { render :json => @images.to_json }
    end
  end
end
