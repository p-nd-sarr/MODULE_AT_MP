#!/bin/sh

set -e

if [ -f tmp/pids/server.pid ]; then
  rm tmp/pids/server.pid
fi

bundle exec rake assets:precompile

#bundle exec whenever --update-crontab && cron -f &

exec "$@"