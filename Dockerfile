FROM ruby:2.7.8-slim

ENV BUNDLER_VERSION=2.1.4

RUN apt-get update -qq &&  \
    apt install -y imagemagick autoconf bison build-essential libssl-dev libyaml-dev libreadline6-dev zlib1g-dev  \
     libncurses5-dev libffi-dev libgdbm-dev mupdf-tools curl wget libaio1 unzip libmariadb-dev libpq-dev && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /usr/share/doc /usr/share/man

RUN gem install bundler -v 2.1.4

# Install Instantclient Basic Light Oracle and Dependencies
ENV ORACLE_HOME=/opt/oracle
ENV LD_LIBRARY_PATH=/opt/oracle/lib

RUN wget -q https://download.oracle.com/otn_software/linux/instantclient/19800/instantclient-basic-linux.x64-19.8.0.0.0dbru.zip \
 && wget -q https://download.oracle.com/otn_software/linux/instantclient/19800/instantclient-sdk-linux.x64-19.8.0.0.0dbru.zip \
 && wget -q https://download.oracle.com/otn_software/linux/instantclient/19800/instantclient-sqlplus-linux.x64-19.8.0.0.0dbru.zip \
 && unzip instantclient-basic-linux.x64-19.8.0.0.0dbru.zip \
 && unzip instantclient-sdk-linux.x64-19.8.0.0.0dbru.zip \
 && unzip instantclient-sqlplus-linux.x64-19.8.0.0.0dbru.zip \
 && mkdir -p $ORACLE_HOME \
 && mv instantclient_19_8 $ORACLE_HOME/lib \
 && rm -f instantclient-*.zip

RUN gem install ruby-oci8 -v '2.2.12' -- --with-oci-dir=$ORACLE_HOME/lib --with-oci-lib --with-oci-include

WORKDIR /app

COPY Gemfile Gemfile.lock ./

RUN bundle config build.nokogiri --use-system-libraries

RUN bundle check || bundle install

RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - && \
    echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list && \
    apt-get update -qq && apt-get install -y yarn
RUN yarn install

COPY package.json ./

RUN yarn install --check-files

COPY . ./

RUN mkdir -p /app/tmp/pids && mkdir -p /app/tmp/sockets

ENTRYPOINT ["./entrypoints/docker-entrypoint.sh"]
