ENV['RACK_ENV'] ||= 'development'

require 'rubygems'
require 'bundler'

Bundler.require(:default, ENV['RACK_ENV'].to_sym)

require 'yaml'

def redis_config
  begin
    return YAML.load(File.open('./config/redis.yml'))[ENV['RACK_ENV']]
  rescue Errno::ENOENT => e
    puts 'No Redis configuration found!'
    puts 'Must provide configuration in config/redis.yml'
    puts "Error Message: #{e.message}"
    exit(0)
  end
end
