# config valid only for current version of Capistrano
lock '3.4.0'

set :application, 'url_shortener'
set :repo_url, 'git@github.com:pcrglennon/url_shortener.git'
set :branch, 'master'

set :linked_files, %w{config/redis.yml}

set :deploy_to, '/var/www/url_shortener'
