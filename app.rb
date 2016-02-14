require './config/environment'

module UrlShortener
  class App < Sinatra::Application
    COUNT = 'count'

    get '/' do
      erb :index
    end

    post '/' do
      url = params['url']
      next_available_hex_key = REDIS.incr(COUNT).to_s(16)
      REDIS.mset(next_available_hex_key, url)

      201
    end
  end
end
