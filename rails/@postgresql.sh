#!/usr/bin/env zsh
set -euo pipefail

if ! command_exists psql; then
  print "PostgreSQL is not installed. Installing..."
  doas pkg_add -U postgresql-server || { print "Failed to install PostgreSQL."; exit 1; }
  doas rcctl enable postgresql
  doas rcctl start postgresql
fi

createuser -s "${APP}" 2>/dev/null || print "Role ${APP} already exists."
createdb "${APP}_development" 2>/dev/null || print "Database ${APP}_development already exists."
createdb "${APP}_test" 2>/dev/null || print "Database ${APP}_test already exists."
createdb "${APP}_production" 2>/dev/null || print "Database ${APP}_production already exists."

cat <<EOF > config/database.yml
default: &default
  adapter: postgresql
  encoding: unicode
  username: ${APP}
  password: password
  host: localhost
  pool: <%= ENV.fetch("RAILS_MAX_THREADS") { 5 } %>

development:
  <<: *default
  database: ${APP}_development

test:
  <<: *default
  database: ${APP}_test

production:
  <<: *default
  database: ${APP}_production
EOF

print "PostgreSQL setup complete."

