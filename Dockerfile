FROM ruby:2.2.0

MAINTAINER Peter Glennon <pcrglennon@gmail.com>

RUN apt-get update -qq && apt-get install -y build-essential

ENV APP_ROOT /app
RUN mkdir $APP_ROOT
WORKDIR $APP_ROOT
ADD . $APP_ROOT
RUN bundle install
