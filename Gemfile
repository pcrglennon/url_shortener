source 'https://rubygems.org'
ruby '2.2.0'

gem 'sinatra', '~> 1.4.7', require: 'sinatra/base'
gem 'thin', '~> 1.6'
gem 'redis', '~>3.2'

group :development do
  gem 'shotgun', '~> 0.9.1'
end

group :test do
  gem 'rspec', '~> 3.4'
end

group :development, :test do
  gem 'pry', '~> 0.10.3'
  gem 'rack-test', '~> 0.6.3'
end
