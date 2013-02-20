require "json"
require "net/http"
require "net/https"

module Api
  class GettyConnect
    attr_accessor :system_id, :system_pwd, :user_name, :user_pwd

    def initialize
      @system_id = "10212"
      @system_pwd = "RQdCMXOOyWHnUhhQtuivnx8NzEOIXINfsa5zSFPJGK4="
      @user_name = "hackathon2012"
      @user_pwd = "sPEbA41EPPXbamy"

      # initialize api by getting a token
      create_session
    end

    def create_session
      endpoint = "https://connect.gettyimages.com/v1/session/CreateSession"
      request = {
          :RequestHeader =>
              {
                  :Token => ""
              },
          :CreateSessionRequestBody =>
              {
                  :SystemId => @system_id,
                  :SystemPassword => @system_pwd,
                  :UserName => @user_name,
                  :UserPassword => @user_pwd
              }
      }

      response = post_json(request, endpoint)
      @token = response["CreateSessionResult"]["Token"]
      @secure_token = response["CreateSessionResult"]["SecureToken"]
      @status = response["ResponseHeader"]["Status"]

      return @status 
    end
      
    def search_image(phrase, num_of_images = 10)
      images_return = []
      current_step = 0;
      begin
        # precaculate the steps of the interval to get
        if (num_of_images >= 75)
          num_step = 75
        else
          num_step = num_of_images
        end

        endpoint = "http://connect.gettyimages.com/v1/search/SearchForImages"
        request = {
            :RequestHeader => { :Token => @token},
            :SearchForImages2RequestBody => {
                :Query => { :SearchPhrase => phrase},
                :ResultOptions => {
                    :ItemCount => num_step,
                    :ItemStartNumber => current_step+1
                },
                :Filter => { :ImageFamilies => ["editorial", "creative"] }
            }
        }

        response = post_json(request, endpoint)

        if (response['ResponseHeader']['Status'] == 'success')
          images = response['SearchForImagesResult']['Images']
          images.each do |the_image|
            image_details_response = get_details(the_image["ImageId"])
            image_details = image_details_response["GetImageDetailsResult"]["Images"].first

            image_data = {
              'image' => the_image["UrlPreview"],
              'city' => image_details["City"],
              'date_created' => image_details["DateCreated"],
              'caption' => image_details["Caption"],
              'image_faily' => image_details["ImageFamily"],
              'title' => image_details["Title"],
              'word' => phrase
            }

            images_return << image_data
          end
        else 
          return response;
        end

        current_step += 75
        num_of_images -= 75
      end while num_of_images > 0
      return images_return
    end

    def get_details(image_id)
      endpoint = "http://connect.gettyimages.com/v1/search/GetImageDetails"
      request = {
          :RequestHeader => { :Token => @token},
          :GetImageDetailsRequestBody => {
              :ImageIds => [
                image_id
              ]
          }
      }

      response = post_json(request, endpoint)
      return response
    end

    def post_json(request, endpoint)
      #You may wish to replace this code with your preferred library for posting and receiving JSON data.
      uri = URI.parse(endpoint)
      http = Net::HTTP.new(uri.host, 443)
      http.use_ssl = true

      response = http.post(uri.path, request.to_json, {'Content-Type' =>'application/json'}).body
      JSON.parse(response)
    end
  end
end
