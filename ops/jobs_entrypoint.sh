#!/usr/bin/env bash
set -euo pipefail

bundle install --jobs 4 --retry 3

DB_HOST="${DB_HOST:-db}"
DB_PORT="${DB_PORT:-5432}"
until (echo >/dev/tcp/"$DB_HOST"/"$DB_PORT") >/dev/null 2>&1; do
  sleep 1
done

bundle exec sidekiq -C config/sidekiq.yml
