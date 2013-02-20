module Api
  class Geo 
    def initialize
    end

    def decode(city_name)
      geo = Geocoder.search("New York City").first
      coord = geo.geometry['location']
      return {
        'long' => coord['lng'],
        'lat' => coord['lat']
      }
    end

    def encode(coord_string)
      geo = Geocoder.search(coord_string)
      return geo
    end
  end
end
