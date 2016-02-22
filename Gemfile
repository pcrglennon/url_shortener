source 'https://rubygems.org'
ruby '2.2.0'

gem 'sinatra', '~> 1.4.7', require: 'sinatra/base'
gem 'unicorn', '~> 5.0', '>= 5.0.1'
gem 'redis', '~>3.2'
gem 'json'

group :test do
  gem 'rspec', '~> 3.4'
end

group :development, :test do
  gem 'pry', '~> 0.10.3'
  gem 'rack-test', '~> 0.6.3'
end
