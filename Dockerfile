ARG DEBIAN_VERSION=bookworm
ARG RUBY_VERSION=3.3

FROM ruby:$RUBY_VERSION-$DEBIAN_VERSION AS base


#FROM phusion/passenger-ruby33:latest AS base

ARG REPO_URL=https://github.com/notch8/archives_online.git

RUN echo 'Downloading Packages' && \
    curl -sL https://deb.nodesource.com/setup_22.x | bash - && \
    apt-get update -qq && \
    apt-get install -y \
      build-essential \
      gettext \
      libsasl2-dev \
      netcat-openbsd \
      nodejs \
      pv \
      rsync \
      tzdata \
      default-mysql-client \
      zip && \
      npm install --global yarn && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    echo 'Packages Downloaded'

# Set up app home
ENV APP_HOME /app/webapp
RUN useradd -m -u 1001 -U -s /bin/bash --home-dir /app app
RUN mkdir $APP_HOME && chown -R app:app /app
WORKDIR $APP_HOME

# Bundle settings
ENV BUNDLE_GEMFILE=$APP_HOME/Gemfile \
  BUNDLE_JOBS=4

# Install basic gems
COPY --chown=app:app Gemfile* $APP_HOME/
RUN bundle check || bundle install

# Web stage
FROM base AS app

# Install bundler version you need
RUN gem install bundler -v 2.4.22

# App files
COPY --chown=app:app Gemfile* $APP_HOME/
RUN bundle check || bundle install

# Copy application code
COPY --chown=app:app . $APP_HOME

# Precompile assets
RUN cd /app/webapp && \
    yarn install && \
    NODE_ENV=production DB_ADAPTER=nulldb bundle exec rake assets:precompile

