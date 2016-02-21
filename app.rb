require './config/environment'

module UrlShortener
  class App < Sinatra::Application
    configure do
      COUNT = 'count'
      HITS = 'hits'
      REDIS = Redis.new(redis_config)
    end

    get '/' do
      @top_links = get_top_links(100)
      erb :index
    end

    get '/:key' do
      begin
        key = params['key']
        url = find_url(key)
        increment_hits(key)
        redirect to(url)
      rescue KeyNotFoundError => e
        @error = e.message
        @top_links = get_top_links(100)
        erb :index
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

    def increment_hits(key)
      REDIS.zincrby(HITS, 1, key)
    end

    def get_top_links(count)
      REDIS.zrevrange(HITS, 0, (count - 1)).map do |key|
        begin
          "#{key} (#{find_url(key)})"
        rescue KeyNotFoundError
          nil
        end
      end.compact
    end
  end

  class InvalidUrlError < StandardError; end
  class KeyNotFoundError < StandardError; end
end
