#!/usr/bin/env bash
set -euo pipefail

bundle install --jobs 4 --retry 3

DB_HOST="${DB_HOST:-db}"
DB_PORT="${DB_PORT:-5432}"
until (echo >/dev/tcp/"$DB_HOST"/"$DB_PORT") >/dev/null 2>&1; do
  sleep 1
done

bundle exec rails db:prepare
bundle exec rails s -p 3000 -b '0.0.0.0'
