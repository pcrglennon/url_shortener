require './config/environment'

module UrlShortener
  class App < Sinatra::Application
    COUNT = 'count'

    get '/' do
      erb :index
    end

    post '/' do
      begin
        key = make_key(params['url'])
        @shortened = "#{request.base_url}/#{key}"
      rescue InvalidUrlError => e
        @error = e.message
      end

      erb :index
    end

    private

    def make_key(url)
      if url =~ URI::regexp(['http', 'https'])
        next_available_hex_key = REDIS.incr(COUNT).to_s(16)
        REDIS.mset(next_available_hex_key, url)

        next_available_hex_key
      else
        raise InvalidUrlError, "Invalid URL: \"#{url}\""
      end
    end
  end

  class InvalidUrlError < StandardError; end
end
