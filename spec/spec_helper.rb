ENV['RACK_ENV'] = 'test'

require File.expand_path '../../app.rb', __FILE__

RSpec.configure do |config|
  include Rack::Test::Methods

  config.after(:example) do
    Redis.connect(REDIS_CONFIG).flushdb
  end
end
