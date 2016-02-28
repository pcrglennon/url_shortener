require './config/environment'

module UrlShortener
  class App < Sinatra::Application
    COUNT = '_count'
    TOP_LINKS = TopLinks.new

    get '/' do
      render_index
    end

    get '/:key' do
      begin
        key = params['key']
        url = find_url(key)
        TOP_LINKS.increment(key)
        redirect to(url)
      rescue KeyNotFoundError => e
        @error = e.message
        render_index
      end
    end

    post '/' do
      content_type :json

      begin
        key = make_key(params['url'])
        [201, {key: key}.to_json]
      rescue InvalidUrlError => e
        [400, {message: e.message}.to_json]
      end
    end

    private

    def render_index
      @top_links = TOP_LINKS.links(100)
      erb :index
    end

    def make_key(url)
      if url =~ URI::regexp(['http', 'https'])
        next_available_hex_key = REDIS.incr(COUNT).to_s(16)
        REDIS.mset(next_available_hex_key, url)

        next_available_hex_key
      else
        raise InvalidUrlError, "Invalid URL: \"#{url}\""
      end
    end

    def find_url(key)
      url = REDIS.get(key)
      if url.nil?
        raise KeyNotFoundError, "Could not find a link for key #{key}"
      end

      url
    end
  end

  class InvalidUrlError < StandardError; end
  class KeyNotFoundError < StandardError; end
end
