require 'rubygems'
require 'bundler'

Bundler.require(:default, ENV.fetch('RACK_ENV', 'development').to_sym)

module UrlShortener
  class App < Sinatra::Application
    redis = Redis.new(host: ENV['REDIS_1_PORT_6379_TCP_ADDR'])

    get '/' do
      erb :index
    end
  end
end
