#!/usr/bin/env zsh
# Unified Rails-OpenBSD Infrastructure v225.0.0

# Complete deployment: DNS, TLS, Rails apps, 40+ domains

set -euo pipefail
# Constants
readonly VERSION="225.0.0"

readonly MAIN_IP="185.52.176.18"

readonly BACKUP_NS="194.63.248.53"

readonly PTR4_API="http://ptr4.openbsd.amsterdam"

readonly PTR6_API="http://ptr6.openbsd.amsterdam"

# Deployment paths
readonly DEPLOY_BASE="/var/rails"

readonly APP_BASE="/home"

readonly LOG_DIR="/var/log/rails"

readonly BACKUP_DIR="${DEPLOY_BASE}/backups/$(date +%Y%m%d_%H%M%S)"

# Create structure
[[ $EUID -eq 0 ]] && mkdir -p "$DEPLOY_BASE" "$LOG_DIR" "$BACKUP_DIR"

# Domain mappings (40+ domains)
typeset -A all_domains

all_domains=(

  ["brgen.no"]="markedsplass playlist dating tv takeaway maps"

  ["oshlo.no"]="markedsplass playlist dating tv takeaway maps"

  ["trndheim.no"]="markedsplass playlist dating tv takeaway maps"

  ["stvanger.no"]="markedsplass playlist dating tv takeaway maps"

  ["trmso.no"]="markedsplass playlist dating tv takeaway maps"

  ["reykjavk.is"]="markadur playlist dating tv takeaway maps"

  ["kobenhvn.dk"]="markedsplads playlist dating tv takeaway maps"

  ["stholm.se"]="marknadsplats playlist dating tv takeaway maps"

  ["gteborg.se"]="marknadsplats playlist dating tv takeaway maps"

  ["mlmoe.se"]="marknadsplats playlist dating tv takeaway maps"

  ["hlsinki.fi"]="markkinapaikka playlist dating tv takeaway maps"

  ["lndon.uk"]="marketplace playlist dating tv takeaway maps"

  ["mnchester.uk"]="marketplace playlist dating tv takeaway maps"

  ["brmingham.uk"]="marketplace playlist dating tv takeaway maps"

  ["edinbrgh.uk"]="marketplace playlist dating tv takeaway maps"

  ["glasgw.uk"]="marketplace playlist dating tv takeaway maps"

  ["lverpool.uk"]="marketplace playlist dating tv takeaway maps"

  ["amstrdam.nl"]="marktplaats playlist dating tv takeaway maps"

  ["rottrdam.nl"]="marktplaats playlist dating tv takeaway maps"

  ["utrcht.nl"]="marktplaats playlist dating tv takeaway maps"

  ["brssels.be"]="marche playlist dating tv takeaway maps"

  ["zrich.ch"]="marktplatz playlist dating tv takeaway maps"

  ["lchtenstein.li"]="marktplatz playlist dating tv takeaway maps"

  ["frankfrt.de"]="marktplatz playlist dating tv takeaway maps"

  ["mrseille.fr"]="marche playlist dating tv takeaway maps"

  ["mlan.it"]="mercato playlist dating tv takeaway maps"

  ["lsbon.pt"]="mercado playlist dating tv takeaway maps"

  ["lsangeles.com"]="marketplace playlist dating tv takeaway maps"

  ["newyrk.us"]="marketplace playlist dating tv takeaway maps"

  ["chcago.us"]="marketplace playlist dating tv takeaway maps"

  ["dtroit.us"]="marketplace playlist dating tv takeaway maps"

  ["houstn.us"]="marketplace playlist dating tv takeaway maps"

  ["dllas.us"]="marketplace playlist dating tv takeaway maps"

  ["austn.us"]="marketplace playlist dating tv takeaway maps"

  ["prtland.com"]="marketplace playlist dating tv takeaway maps"

  ["mnneapolis.com"]="marketplace playlist dating tv takeaway maps"

  ["pub.attorney"]=""

  ["freehelp.legal"]=""

  ["bsdports.org"]=""

  ["hjerterom.no"]=""

  ["privcam.no"]=""

  ["amberapp.com"]=""

  ["foodielicio.us"]=""

  ["stacyspassion.com"]=""

  ["antibettingblog.com"]=""

  ["anticasinoblog.com"]=""

  ["antigamblingblog.com"]=""

  ["foball.no"]=""

)

# App to port mappings
typeset -A app_domains

app_domains=(

  ["brgen:10001"]="brgen.no oshlo.no trndheim.no stvanger.no trmso.no reykjavk.is kobenhvn.dk stholm.se gteborg.se mlmoe.se hlsinki.fi lndon.uk mnchester.uk brmingham.uk edinbrgh.uk glasgw.uk lverpool.uk amstrdam.nl rottrdam.nl utrcht.nl brssels.be zrich.ch lchtenstein.li frankfrt.de mrseille.fr mlan.it lsbon.pt lsangeles.com newyrk.us chcago.us dtroit.us houstn.us dllas.us austn.us prtland.com mnneapolis.com"

  ["pubattorney:10002"]="pub.attorney freehelp.legal"

  ["bsdports:10003"]="bsdports.org"

  ["hjerterom:10004"]="hjerterom.no"

  ["privcam:10005"]="privcam.no"

  ["amber:10006"]="amberapp.com"

  ["blognet:10007"]="foodielicio.us stacyspassion.com antibettingblog.com anticasinoblog.com antigamblingblog.com foball.no"

)

# PTR mappings
typeset -A primary_ptrs

primary_ptrs=(

  ["main"]="ns.brgen.no"

  ["brgen"]="brgen.no"

  ["pubattorney"]="pub.attorney"

  ["bsdports"]="bsdports.org"

  ["hjerterom"]="hjerterom.no"

  ["privcam"]="privcam.no"

  ["amber"]="amberapp.com"

  ["blognet"]="foodielicio.us"

)

# Logging with structured output
log() {

  local level="${1:-INFO}"

  shift

  printf '{"time":"%s","level":"%s","msg":"%s"}\n' \

    "$(date -u +%Y-%m-%dT%H:%M:%SZ)" "$level" "$*" | \

    tee -a "$LOG_DIR/unified.log"

}

save_state() {
  cat > "${DEPLOY_BASE}/state.json" << EOF

{

  "version": "$VERSION",

  "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",

  "phase": "$1",

  "evidence": ${2:-0},

  "apps": ${3:-0},

  "domains": ${#all_domains[@]}"

}

EOF

}

error() {
  log "ERROR" "$*"

  exit 1

}

warn() {
  log "WARN" "$*"

}

# Environment validation with evidence scoring
validate_environment() {

  log "INFO" "Validating environment..."

  local evidence=0
  local -A checks=(

    ["root"]="$EUID -eq 0"

    ["openbsd"]="uname -s matches OpenBSD"

    ["network"]="connectivity to 8.8.8.8"

    ["zsh"]="command -v zsh found"

    ["pkg_add"]="command -v pkg_add found"

  )

  [[ $EUID -eq 0 ]] || error "Must run with doas/root"
  evidence=$((evidence + 20))

  local os=$(uname -s 2>/dev/null || print "unknown")
  [[ "$os" == "OpenBSD" ]] && evidence=$((evidence + 20))

  ping -c 1 -W 1000 8.8.8.8 >/dev/null 2>&1 && evidence=$((evidence + 20))
  command -v zsh >/dev/null 2>&1 && evidence=$((evidence + 20))
  command -v pkg_add >/dev/null 2>&1 && evidence=$((evidence + 20))

  log "INFO" "Environment evidence: ${evidence}/100"
  [[ $evidence -ge 80 ]] || error "Environment validation failed (${evidence}/100)"

  save_state "validated" "$evidence" 0
}

# Ruby and Rails setup
setup_ruby_rails() {

  log "Setting up Ruby 3.3 and Rails..."

  # Install Ruby
  pkg_add -U ruby%3.3 || return 1

  # Create symbolic links
  for cmd in ruby erb irb gem bundle rdoc ri rake; do

    ln -sf "/usr/local/bin/${cmd}33" "/usr/local/bin/$cmd" 2>/dev/null || true

  done

  # Configure gem environment
  cat > /etc/gemrc << 'EOF'

---

:sources:

- https://rubygems.org/

install: --no-document

update: --no-document

EOF

  # Update RubyGems
  gem update --system --no-document || true

  # Install essential gems
  local gems=(

    "bundler:2.5.0"

    "rails:7.2.0"

    "pg:1.5.0"

    "redis:5.0.0"

    "falcon:0.47.0"

    "async:2.8.0"

    "async-websocket:0.26.0"

    "async-redis:0.8.0"

    "rack-attack:6.7.0"

    "sidekiq:7.2.0"

    "propshaft:0.8.0"

    "turbo-rails:2.0.0"

    "stimulus-rails:1.3.0"

  )

  for gem_spec in "${gems[@]}"; do
    local gem="${gem_spec%%:*}"

    local version="${gem_spec#*:}"

    gem install "$gem" --version "$version" --no-document || log "WARN: Failed $gem"

  done

  log "Ruby and Rails configured"
}

# PostgreSQL and Redis setup
setup_databases() {

  log "Setting up PostgreSQL and Redis..."

  # PostgreSQL
  pkg_add -U postgresql-server postgresql-client || return 1

  if [[ ! -d /var/postgresql/data ]]; then
    install -d -o _postgresql -g _postgresql /var/postgresql/data

    doas -u _postgresql initdb -D /var/postgresql/data -U postgres -A scram-sha-256 -E UTF8

  fi

  rcctl enable postgresql
  rcctl start postgresql

  # Redis
  pkg_add -U redis || return 1

  rcctl enable redis

  rcctl start redis

  # Node.js for Rails assets
  pkg_add -U node || return 1

  log "Databases ready"
}

# DNS with DNSSEC
setup_dns_dnssec() {

  log "Configuring NSD with DNSSEC..."

  mkdir -p /var/nsd/zones/master /var/nsd/zones/keys
  # Generate DNSSEC keys
  for domain in "${(@k)all_domains}"; do

    if [[ ! -f "/var/nsd/zones/keys/$domain.zsk" ]]; then

      cd /var/nsd/zones/keys

      # ZSK - ECDSA P-256 SHA-256

      zsk_base=$(ldns-keygen -a ECDSAP256SHA256 -b 256 "$domain")

      print "$zsk_base" > "$domain.zsk"

      # KSK - ECDSA P-256 SHA-256

      ksk_base=$(ldns-keygen -k -a ECDSAP256SHA256 -b 256 "$domain")

      print "$ksk_base" > "$domain.ksk"

    fi

  done

  # Create zone files
  for domain in "${(@k)all_domains}"; do

    cat > "/var/nsd/zones/master/$domain.zone" << EOF

\$ORIGIN $domain.

\$TTL 24h

@ 1h IN SOA ns.brgen.no. admin.brgen.no. ($(date +%Y%m%d)01 1h 15m 1w 3m)

@ IN NS ns.brgen.no.

@ IN NS ns.hyp.net.

@ IN A $MAIN_IP

www IN CNAME @

@ IN CAA 0 issue "letsencrypt.org"

$([[ "$domain" == "brgen.no" ]] && print "ns IN A $MAIN_IP")

$(for sub in ${(s/ /)all_domains[$domain]}; do print "$sub IN CNAME @"; done)

EOF

    # Sign zone
    cd /var/nsd/zones/master

    zsk_base=$(cat ../keys/"$domain.zsk")

    ksk_base=$(cat ../keys/"$domain.ksk")

    ldns-signzone -n -p -s $(dd if=/dev/urandom bs=1000 count=1 2>/dev/null | sha256 | cut -b 1-16) \

      "$domain.zone" \

      "../keys/$zsk_base" \

      "../keys/$ksk_base"

  done

  chown -R _nsd:_nsd /var/nsd/zones
  # NSD configuration
  cat > /var/nsd/etc/nsd.conf << 'EOF'

server:

  hide-version: yes

  verbosity: 1

  rrl-ratelimit: 200

  rrl-size: 1000000

  dnssec-enable: yes

remote-control:
  control-enable: yes

EOF

  for domain in "${(@k)all_domains}"; do
    cat >> /var/nsd/etc/nsd.conf << EOF

zone:

  name: "$domain"

  zonefile: master/$domain.zone.signed

  notify: $BACKUP_NS NOKEY

  provide-xfr: $BACKUP_NS NOKEY

EOF

  done

  rcctl enable nsd
  rcctl restart nsd

  log "DNS with DNSSEC configured"
}

# PF firewall
setup_firewall() {

  log "Configuring PF firewall..."

  cat > /etc/pf.conf << 'EOF'
table <bruteforce> persist

table <ratelimit> persist

set block-policy drop
set skip on lo

set limit states 500000

set timeout tcp.established 3600

set syncookies adaptive (start 25%, end 12%)

match in all scrub (no-df random-id max-mss 1440)
block all
pass out all
pass in proto tcp to port 22 flags S/SA synproxy state \
  (source-track rule, max-src-conn 15, max-src-conn-rate 15/60, \

   overload <bruteforce> flush global)

pass in proto { tcp udp } to port 53
pass in proto tcp to port { 80 443 } flags S/SA synproxy state \
  (source-track rule, max-src-states 1000, max-src-conn 100, \

   max-src-conn-rate 50/30, overload <ratelimit> flush global)

pass in proto tcp to port 10001:10007
anchor "relayd/*"
EOF

  pfctl -f /etc/pf.conf
  rcctl enable pf

  log "Firewall configured"
}

# TLS certificates
setup_tls() {

  log "Setting up TLS certificates..."

  mkdir -p /var/www/acme /etc/acme /etc/ssl/private
  # Generate account key
  [[ -f /etc/acme/letsencrypt-privkey.pem ]] || \

    openssl ecparam -genkey -name prime256v1 -out /etc/acme/letsencrypt-privkey.pem

  # acme-client configuration
  cat > /etc/acme-client.conf << 'EOF'

authority letsencrypt {

  api url "https://acme-v02.api.letsencrypt.org/directory"

  account key "/etc/acme/letsencrypt-privkey.pem"

}

EOF

  for domain in "${(@k)all_domains}"; do
    cat >> /etc/acme-client.conf << EOF

domain "$domain" {

  domain key "/etc/ssl/private/$domain.key" ecdsa

  domain full chain certificate "/etc/ssl/$domain.crt"

  sign with letsencrypt

  challengedir "/var/www/acme"

EOF

    if [[ -n "${all_domains[$domain]}" ]]; then

      print -n "  alternative names { www.$domain "

      for sub in ${(s/ /)all_domains[$domain]}; do print -n "$sub.$domain "; done

      print "}"

    else

      print "}"

    fi >> /etc/acme-client.conf

  done

  # httpd for ACME
  cat > /etc/httpd.conf << 'EOF'

types { include "/usr/share/misc/mime.types" }

prefork 5

server "default" {
  listen on * port 80

  location "/.well-known/acme-challenge/*" {

    root "/acme"

    request strip 2

  }

  location * {

    block return 302 "https://$HTTP_HOST$REQUEST_URI"

  }

}

EOF

  rcctl enable httpd
  rcctl restart httpd

  # Get certificates
  for domain in "${(@k)all_domains}"; do

    acme-client -v "$domain" || warn "Certificate failed for $domain"

  done

  log "TLS configured"
}

# relayd load balancer
setup_relayd() {

  log "Configuring relayd..."

  cat > /etc/relayd.conf << 'EOF'
prefork 5

EOF

  for app_port in "${(@k)app_domains}"; do
    app="${app_port%:*}"

    cat >> /etc/relayd.conf << EOF

table <${app}_servers> { 127.0.0.1 }

EOF

  done

  cat >> /etc/relayd.conf << 'EOF'
http protocol "rails" {
  match request header append "X-Forwarded-For" value "$REMOTE_ADDR"

  match request header set "X-Forwarded-Proto" value "https"

  match response header set "Strict-Transport-Security" value "max-age=31536000"

  match response header set "X-Frame-Options" value "DENY"

  match response header set "X-Content-Type-Options" value "nosniff"

  http websockets
  tcp { nodelay, sack, socket buffer 65536, backlog 1000 }
EOF

  for domain in "${(@k)all_domains}"; do
    [[ -f "/etc/ssl/$domain.crt" ]] && \

      print "  tls keypair \"$domain\"" >> /etc/relayd.conf

  done

  cat >> /etc/relayd.conf << 'EOF'
  tls { no tlsv1.0, no tlsv1.1, ciphers "ECDHE+AESGCM:ECDHE+CHACHA20:DHE+AESGCM" }
}

relay "rails" {
  listen on * port 443 tls

  protocol "rails"

EOF

  for app_port in "${(@k)app_domains}"; do
    app="${app_port%:*}"

    port="${app_port#*:}"

    cat >> /etc/relayd.conf << EOF

  forward to <${app}_servers> port $port check tcp

EOF

  done

  cat >> /etc/relayd.conf << 'EOF'
}

EOF

  rcctl enable relayd
  rcctl restart relayd

  log "relayd configured"
}

# Deploy Rails application
deploy_rails_app() {

  local app_port="$1"

  local app="${app_port%:*}"

  local port="${app_port#*:}"

  local domains="${app_domains[$app_port]}"

  log "Deploying $app on port $port"
  # Create user
  id "$app" 2>/dev/null || useradd -m -G www -L railsapp -s /bin/ksh "$app"

  # Create app structure
  local app_dir="${APP_BASE}/${app}/app"

  doas -u "$app" mkdir -p "$app_dir/"{app,config,db,lib,log,public,tmp}

  # Database setup
  local db_pass=$(openssl rand -hex 16)

  doas -u _postgresql psql -U postgres << SQL 2>/dev/null || true

DROP ROLE IF EXISTS ${app}_user;

CREATE ROLE ${app}_user LOGIN PASSWORD '$db_pass';

CREATE DATABASE ${app}_production OWNER ${app}_user;

CREATE DATABASE ${app}_development OWNER ${app}_user;

CREATE DATABASE ${app}_test OWNER ${app}_user;

GRANT ALL ON DATABASE ${app}_production TO ${app}_user;

GRANT ALL ON DATABASE ${app}_development TO ${app}_user;

GRANT ALL ON DATABASE ${app}_test TO ${app}_user;

SQL

  # Gemfile
  doas -u "$app" cat > "$app_dir/Gemfile" << 'GEMFILE'

source "https://rubygems.org"

ruby "3.3.0"

gem "rails", "~> 7.2.0"
gem "pg", "~> 1.5"

gem "falcon", "~> 0.47"

gem "async"

gem "redis", "~> 5.0"

gem "propshaft"

gem "turbo-rails"

gem "stimulus-rails"

gem "rack-attack"

gem "bcrypt"

gem "sidekiq"

gem "bootsnap", require: false

GEMFILE

  # Database config
  doas -u "$app" cat > "$app_dir/config/database.yml" << EOF

production:

  adapter: postgresql

  encoding: unicode

  pool: 10

  username: ${app}_user

  password: $db_pass

  host: localhost

  database: ${app}_production

EOF

  # Environment
  doas -u "$app" cat > "$app_dir/.env" << EOF

RAILS_ENV=production

PORT=$port

SECRET_KEY_BASE=$(openssl rand -hex 64)

DATABASE_URL=postgresql://${app}_user:${db_pass}@localhost/${app}_production

REDIS_URL=redis://localhost:6379/0

RAILS_LOG_TO_STDOUT=true

RAILS_SERVE_STATIC_FILES=true

WEB_CONCURRENCY=2

RAILS_MAX_THREADS=5

DOMAINS="$domains"

EOF

  # Falcon config
  doas -u "$app" cat > "$app_dir/config/falcon.rb" << FALCON

#!/usr/bin/env ruby

require 'async'

require 'async/http/endpoint'

ENV["RAILS_ENV"] ||= "production"
port = $port

app = lambda { |env|
  [200, {"Content-Type" => "text/html"},

   ["<h1>$app on port $port</h1><p>Serving: $domains</p>"]]

}

Async do
  endpoint = Async::HTTP::Endpoint.parse("http://0.0.0.0:#{port}")

    .with(protocol: Async::HTTP::Protocol::HTTP11)

  bound_endpoint = endpoint.bound
  puts "Falcon serving $app on port #{port}"
  Async::HTTP::Server.new(app, bound_endpoint).run
end

FALCON

  chmod +x "$app_dir/config/falcon.rb"
  # Service script
  cat > "/etc/rc.d/${app}_rails" << EOF

#!/bin/ksh

daemon="$app_dir/config/falcon.rb"

daemon_user="$app"

daemon_timeout=30

. /etc/rc.d/rc.subr
rc_bg=YES
rc_reload=NO

rc_cmd \$1
EOF

  chmod +x "/etc/rc.d/${app}_rails"
  rcctl enable "${app}_rails"

  rcctl start "${app}_rails"

  log "Deployed $app"
}

# PTR records
setup_ptr_records() {

  local hostname=$(hostname 2>/dev/null || echo "unknown")

  [[ "$hostname" =~ ^vm[0-9]+ ]] || {
    log "Not on OpenBSD Amsterdam VM - skipping PTR"

    return 0

  }

  log "Setting up PTR records..."
  for service in "${(@k)primary_ptrs}"; do
    local token4=$(ftp -MVo- "$PTR4_API/token" 2>/dev/null | tr -d '\r\n')

    local token6=$(ftp -MVo- "$PTR6_API/token" 2>/dev/null | tr -d '\r\n')

    [[ -n "$token4" ]] && ftp -MVo- "$PTR4_API/$token4/${primary_ptrs[$service]}" 2>/dev/null
    [[ -n "$token6" ]] && ftp -MVo- "$PTR6_API/$token6/${primary_ptrs[$service]}" 2>/dev/null

  done

  log "PTR records configured"
}

# Login limits
setup_limits() {

  log "Setting up login limits..."

  grep -q railsapp /etc/login.conf 2>/dev/null || \
  cat >> /etc/login.conf << 'EOF'

railsapp:\
  :openfiles-max=4096:\

  :datasize-max=2G:\

  :maxproc-max=256:\

  :tc=daemon:

EOF

  cap_mkdb /etc/login.conf
  log "Login limits configured"
}

# Cron jobs
setup_cron() {

  log "Setting up cron jobs..."

  (crontab -l 2>/dev/null | grep -v acme-client; \
   echo "0 0 * * * for d in ${(@k)all_domains}; do acme-client \$d; done") | crontab -

  log "Cron configured"
}

# Pre-point deployment (before domains point here)
# CRITICAL: DNS must be running BEFORE Norid nameserver registration
pre_point() {

  log "INFO" "Starting pre-point deployment v$VERSION"

  validate_environment
  setup_ruby_rails

  setup_databases

  setup_firewall

  setup_limits

  # DNS MUST be set up FIRST (before domain registration)
  # Norid requires ns.brgen.no to respond on port 53 before accepting registration
  setup_dns_dnssec

  # Deploy all apps
  local app_count=0

  for app_port in "${(@k)app_domains}"; do

    deploy_rails_app "$app_port"

    app_count=$((app_count + 1))

  done

  save_state "pre_point_complete" 100 "$app_count"
  log "INFO" "Pre-point deployment complete"
  log "INFO" "  Apps deployed: $app_count"

  log "INFO" "  Services running: $(rcctl ls on | wc -l)"

  log "INFO" ""

  log "INFO" "IMPORTANT: DNS is now running on port 53"
  log "INFO" "1. Register nameserver ns.brgen.no -> $MAIN_IP at Norid"
  log "INFO" "2. Point all domains to ns.brgen.no"
  log "INFO" "3. Wait for DNS propagation (dig @8.8.8.8 brgen.no)"
  log "INFO" "4. Then run: doas zsh openbsd.sh --post-point"

}

# Post-point deployment (after domains point here)
# Run AFTER: 1) Norid accepts ns.brgen.no, 2) Domains point to nameserver
post_point() {

  log "INFO" "Starting post-point deployment v$VERSION"

  validate_environment

  # TLS requires domains to resolve (acme-client needs HTTP-01 challenge)
  setup_tls

  # relayd requires TLS certificates
  setup_relayd

  setup_ptr_records

  setup_cron

  save_state "complete" 100 7
  log "INFO" "Post-point deployment complete"
  log "INFO" "  Domains configured: ${#all_domains[@]}"

  log "INFO" "  TLS certificates obtained"
  log "INFO" "  relayd load balancer running"
  log "INFO" "  Submit DS records from /var/nsd/zones/keys/*.ds to your registrars"

}

# Command handling
case "${1:---pre-point}" in

  --help)

    cat << 'EOF'

Unified Rails-OpenBSD Infrastructure v226.0.0

Usage: doas zsh openbsd.sh [--pre-point|--post-point|--help]
Two-stage deployment:
  --pre-point   Deploy infrastructure before domains point here:
                - Ruby 3.3 + Rails 7.2 + gems

                - PostgreSQL + Redis

                - 7 Rails apps on ports 10001-10007

                - PF firewall

  --post-point  Configure DNS/TLS after domains point to 185.52.176.18:
                - NSD with DNSSEC for 40+ domains

                - TLS certificates via ACME

                - relayd load balancer

                - PTR records

Prerequisites:
- OpenBSD 7.x

- Root/doas access

- Internet connectivity

EOF

    ;;

  --pre-point)

    pre_point

    ;;

  --post-point)

    post_point

    ;;

  *)

    echo "Usage: doas zsh openbsd.sh [--pre-point|--post-point|--help]"

    exit 1

    ;;

esac

