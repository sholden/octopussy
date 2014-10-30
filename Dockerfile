FROM ruby
RUN apt-get update -qq && apt-get install -y build-essential nodejs npm git curl mysql-client libmysqlclient-dev
RUN mkdir /shard_demo
WORKDIR /shard_demo
ADD Gemfile* /shard_demo/
RUN bundle install
RUN echo "gem: --no-rdoc --no-ri" >> ~/.gemrc
ADD . /shard_demo