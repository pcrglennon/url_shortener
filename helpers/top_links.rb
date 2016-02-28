module UrlShortener
  class TopLinks
    HITS = '_hits'

    def links(count)
      cached_links(count) || calculate_links(count)
    end

    def increment(key)
      REDIS.zincrby(HITS, 1, key)
    end

    private

    def cached_links(count)
      cached = REDIS.get("_top_#{count}")
      return nil if cached.nil?

      parse_cached(cached)
    end

    def parse_cached(cached)
      JSON.parse(cached, symbolize_names: true)[:links]
    end

    # Regenerate the top links list and cache it
    def calculate_links(count)
      links = fetch_top(count).map do |key, score|
        ranked_link(key, score)
      end.compact

      REDIS.set("_top_#{count}", { links: links }.to_json)
      REDIS.expire("_top_#{count}", 600)  # expire in 10 minutes

      links
    end

    def fetch_top(count)
      # For some reason, zrevrange isn't working here
      REDIS.zrange(HITS, 0, (count - 1), with_scores: true).reverse || []
    end

    def ranked_link(key, score)
      destination = REDIS.get(key)
      return if destination.nil?

      { hits: score.to_i, key: key, destination: destination }
    end
  end
end
