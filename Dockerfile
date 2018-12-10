FROM ruby:2.5.1
MAINTAINER margus.ernits@rangeforce.com

RUN apt-get update -qq && \
    apt-get install -y --no-install-recommends build-essential sudo openssh-client libyaml-0-2 libgmp-dev default-libmysqlclient-dev libsqlite3-dev bundler nodejs cron screen \
    && apt-get clean autoclean \
    && apt-get autoremove -y \
    && rm -rf /var/lib/apt/lists/* \
    && mkdir -p /var/run/sshd /var/labs/run

WORKDIR /var/www/i-tee

# Setting env up
ENV RAILS_ENV='production' \
    RAKE_ENV='production' \
    RAILS_LOG_TO_STDOUT='1' \
    RAILS_SERVE_STATIC_FILES='true'
    
# Adding gems
COPY /Gemfile /var/www/i-tee/Gemfile
COPY /Gemfile.lock /var/www/i-tee/Gemfile.lock

RUN bundle install --jobs 20 --retry 5 --without development test 
# Adding project files

COPY /Rakefile /var/www/i-tee/Rakefile
COPY /config.ru /var/www/i-tee/config.ru
COPY /lib/ /var/www/i-tee/lib/
COPY /script/ /var/www/i-tee/script/
COPY /public/ /var/www/i-tee/public/
COPY /config/ /var/www/i-tee/config/
COPY /db/ /var/www/i-tee/db/
COPY /utils/ /var/www/i-tee/utils/
COPY /app/ /var/www/i-tee/app/
COPY /version.txt /var/www/i-tee/version.txt

COPY /docker/vboxmanage /var/www/i-tee/utils/vboxmanage
COPY /docker/check-resources /var/www/i-tee/utils/check-resources
COPY /docker/application.rb /var/www/i-tee/config/application.rb
COPY /docker/devise.rb /var/www/i-tee/config/initializers/devise.rb
COPY /docker/production.rb /var/www/i-tee/config/environments/production.rb

# Install lab killing cron job
RUN echo "* * * * * . /etc/environment && bash -c 'cd /var/www/i-tee/ && rake RAILS_ENV=production expired_labs:search_and_destroy > /var/www/i-tee/cron.log 2>&1'" | crontab -

RUN RAILS_ENV=production bundle exec rake SECRET_KEY_BASE=for_asset_build  assets:precompile
EXPOSE 80

CMD env >> /etc/environment && /usr/bin/screen -dmS cronjob /usr/sbin/cron -f; bundle exec puma -C config/puma.rb

