FROM ruby:2.5.1
RUN apt-get update && apt-get install -y postgresql-client
RUN mkdir /polydesk-api
WORKDIR /polydesk-api
COPY Gemfile /polydesk-api
COPY Gemfile.lock /polydesk-api
RUN bundle install --binstubs
RUN ip -4 route list match 0/0 | awk '{print $3 "host.docker.internal"}' >> /etc/hosts
COPY . /polydesk-api
LABEL maintainer="Paul Holden <paul@holdensoftware.com>"
EXPOSE 3000
CMD puma -C config/puma.rb
