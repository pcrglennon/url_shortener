ENV['RACK_ENV'] ||= 'development'

require 'rubygems'
require 'bundler'

Bundler.require(:default, ENV['RACK_ENV'].to_sym)

begin
  require 'yaml'
  REDIS_CONFIG = YAML.load(File.open('./config/redis.yml'))[ENV['RACK_ENV']]
  REDIS = Redis.new(REDIS_CONFIG)
rescue Errno::ENOENT => e
  puts 'No Redis configuration found!'
  puts 'Must provide configuration in config/redis.yml'
  exit(0)
end
