require "json"
require "net/http"

module Api
  class Nyt
    def initialize
      @endpoint = 'http://api.nytimes.com/svc/search/v1/article'
      @geo_endpoint = 'http://api.nytimes.com/svc/semantic/v2/geocodes'
      @api_key = 'a33647e077772fbce68937749acf1614:0:67005581'
      @geo_key = '1f40b4b3f45bf757f4b6a415412eb7a0:0:67005581'
    end

    def get_articles(keyword)
      #http://developer.nytimes.com/docs/article_search_api#h2-responses
      # look for 'data fields' can grab
      request = @endpoint+'/?api-key='+@api_key+'&query='+keyword+'&fields=title,date,geo_facet'

      response = get_response(request)
      return response['results']
    end

    def get_geocode(place_name)
      request = @geo_endpoint+'/query.json?name='+place_name+'&api-key='+@geo_key

      response = get_response(request)
      return response['results']
    end

    def get_response(request)
      uri = uri.parse(request)

      response = net::http.get_response(uri).body
      json.parse(response)
    end
  end
end
