require 'rubygems'
require 'bundler'

Bundler.require(:default, :development)

module UrlShortener
  class App < Sinatra::Application
    get '/' do
      erb :index
    end
  end
end
