#!/usr/bin/env zsh
set -e

# OpenBSD Rails Server Setup - Final Version
# Following master.json v81.23.0 formatting and preservation rules
# Universal formatting: double quotes, readable multiline, cat + heredoc

main_ip="46.23.95.45"
backup_ns="194.63.248.53"

# COMPLETE domain array - preserved per data_completeness rules (NO TRUNCATION)
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
  ["antibettingblog.com"]""
  ["anticasinoblog.com"]=""
  ["antigamblingblog.com"]""
  ["foball.no"]=""
)

typeset -A app_ports
app_ports=(
  ["brgen"]=10001
  ["pubattorney"]=10002
  ["bsdports"]=10003
  ["hjerterom"]=10004
  ["privcam"]=10005
  ["amber"]=10006
  ["blognet"]=10007
)

typeset -A app_domains  
app_domains=(
  ["brgen"]="brgen.no oshlo.no trndheim.no stvanger.no trmso.no reykjavk.is kobenhvn.dk stholm.se gteborg.se mlmoe.se hlsinki.fi lndon.uk mnchester.uk brmingham.uk edinbrgh.uk glasgw.uk lverpool.uk amstrdam.nl rottrdam.nl utrcht.nl brssels.be zrich.ch lchtenstein.li frankfrt.de mrseille.fr mlan.it lsbon.pt lsangeles.com newyrk.us chcago.us dtroit.us houstn.us dllas.us austn.us prtland.com mnneapolis.com"
  ["pubattorney"]="pub.attorney freehelp.legal"
  ["bsdports"]="bsdports.org"
  ["hjerterom"]="hjerterom.no"
  ["privcam"]="privcam.no"
  ["amber"]="amberapp.com"
  ["blognet"]="foodielicio.us stacyspassion.com antibettingblog.com anticasinoblog.com antigamblingblog.com foball.no"
)

log() {
  echo "[$(date "+%Y-%m-%d %H:%M:%S")] $1"
}

install_packages() {
  log "Installing system packages..."
  doas pkg_add -U ruby-3.3 postgresql-server redis node falcon nsd
  
  log "Setting up Ruby gems with bundle install..."
  gem update --system
  bundle config set --local path "$HOME/.local/bundle"
  bundle install --user-install bundler
  bundle install --user-install rails
  bundle install --user-install falcon
}

setup_postgresql() {
  log "Setting up PostgreSQL..."
  if [ ! -d /var/postgresql/data ]; then
    doas install -d -o _postgresql -g _postgresql /var/postgresql/data
    doas -u _postgresql initdb -D /var/postgresql/data -U postgres -A scram-sha-256 -E UTF8
  fi
  
  doas rcctl enable postgresql
  doas rcctl start postgresql
  
  log "PostgreSQL initialized and started"
}

setup_pf() {
  log "Configuring packet filter..."
  doas tee /etc/pf.conf > /dev/null << "PF_CONFIG"
ext_if = "vio0"

set skip on lo
table <bruteforce> persist
table <pfbadhost> persist file "/etc/pf-badhost.txt"

set block-policy return
scrub in all
block log all

# Block bad IPs
block in quick on $ext_if from <pfbadhost>
block out quick on $ext_if to <pfbadhost>
block quick from <bruteforce>

pass out quick on $ext_if all

# SSH with brute force protection
pass in on $ext_if proto tcp to port 22 keep state \
  (max-src-conn 15, max-src-conn-rate 5/3, overload <bruteforce> flush global)

# DNS
pass in on $ext_if proto { tcp, udp } to port 53 keep state \
  (max-src-conn 100, max-src-conn-rate 15/5, overload <bruteforce> flush global)

# HTTP/HTTPS
pass in on $ext_if proto tcp to port { 80, 443 } keep state

anchor "relayd/*"
PF_CONFIG

  doas pfctl -f /etc/pf.conf
  doas rcctl enable pf
  log "Packet filter configured and enabled"
}

setup_nsd() {
  log "Setting up NSD DNS server..."
  doas mkdir -p /var/nsd/zones/master /var/nsd/etc
  doas chown -R _nsd:_nsd /var/nsd/zones
  
  for domain in "${(@k)all_domains}"; do
    serial=$(date "+%Y%m%d%H")
    subdomains="${all_domains[$domain]}"
    
    log "Creating zone file for $domain"
    cat > "/tmp/$domain.zone" << ZONE_FILE
\$ORIGIN $domain.
\$TTL 24h

@ 1h IN SOA ns.brgen.no. admin.brgen.no. (
  $serial ; Serial
  1h      ; Refresh  
  15m     ; Retry
  1w      ; Expire
  3m      ; Minimum TTL
)

@ IN NS ns.brgen.no.
@ IN NS ns.hyp.net.

www IN CNAME @
@ IN A $main_ip

; CAA record for Let's Encrypt
@ 3m IN CAA 0 issue "letsencrypt.org"
ZONE_FILE

    # Add nameserver A record for brgen.no
    if [[ "$domain" == "brgen.no" ]]; then
      echo "ns IN A $main_ip" >> "/tmp/$domain.zone"
    fi

    # Add subdomain records
    if [[ -n "$subdomains" ]]; then
      for sub in ${(s/ /)subdomains}; do
        echo "$sub IN CNAME @" >> "/tmp/$domain.zone"
      done
    fi
    
    doas mv "/tmp/$domain.zone" "/var/nsd/zones/master/$domain.zone"
    doas chown _nsd:_nsd "/var/nsd/zones/master/$domain.zone"
  done

  log "Creating NSD configuration..."
  cat > "/tmp/nsd.conf" << NSD_CONFIG
server:
  hide-version: yes
  verbosity: 1

remote-control:
  control-enable: yes

NSD_CONFIG

  for domain in "${(@k)all_domains}"; do
    cat >> "/tmp/nsd.conf" << ZONE_CONFIG

zone:
  name: "$domain"
  zonefile: master/$domain.zone
  notify: $backup_ns NOKEY
  provide-xfr: $backup_ns NOKEY
ZONE_CONFIG
  done
  
  doas mv "/tmp/nsd.conf" /var/nsd/etc/nsd.conf
  doas chown _nsd:_nsd /var/nsd/etc/nsd.conf
  doas rcctl enable nsd
  doas rcctl start nsd
  
  log "NSD configured with ${#all_domains[@]} domains"
}

setup_acme() {
  log "Setting up ACME client..."
  doas mkdir -p /var/www/acme /etc/acme
  doas chown -R www:www /var/www/acme
  
  if [ ! -f /etc/acme/letsencrypt-privkey.pem ]; then
    doas openssl ecparam -name prime256v1 -genkey -out /etc/acme/letsencrypt-privkey.pem
    doas chmod 600 /etc/acme/letsencrypt-privkey.pem
  fi
  
  cat > "/tmp/acme-client.conf" << ACME_CONFIG
authority letsencrypt {
  api url "https://acme-v02.api.letsencrypt.org/directory"
  account key "/etc/acme/letsencrypt-privkey.pem"
}

ACME_CONFIG
  
  for domain in "${(@k)all_domains}"; do
    subdomains="${all_domains[$domain]}"
    
    cat >> "/tmp/acme-client.conf" << DOMAIN_CONFIG

domain "$domain" {
  domain key "/etc/ssl/private/$domain.key"
  domain full chain certificate "/etc/ssl/$domain.crt"
  sign with letsencrypt
  challengedir "/var/www/acme"
DOMAIN_CONFIG
    
    if [[ -n "$subdomains" ]]; then
      alt_names=""
      for sub in ${(s/ /)subdomains}; do
        alt_names+="\"$sub.$domain\" "
      done
      echo "  alternative names { $alt_names}" >> "/tmp/acme-client.conf"
    fi
    
    echo "}" >> "/tmp/acme-client.conf"
  done
  
  doas mv "/tmp/acme-client.conf" /etc/acme-client.conf
  log "ACME client configured for ${#all_domains[@]} domains"
}

setup_httpd() {
  log "Setting up httpd for ACME challenges..."
  cat > "/tmp/httpd.conf" << HTTPD_CONFIG
types { include "/usr/share/misc/mime.types" }

server "acme" {
  listen on localhost port 43718
  location "/.well-known/acme-challenge/*" {
    root "/acme"
    request strip 2
  }
}
HTTPD_CONFIG

  doas mv "/tmp/httpd.conf" /etc/httpd.conf
  doas rcctl enable httpd
  doas rcctl start httpd
  log "httpd configured and started"
}

setup_relayd() {
  log "Setting up relayd for HTTPS->Rails proxying..."
  
  cat > "/tmp/relayd.conf" << RELAYD_HEADER
egress="$main_ip"

table <acme_client> { 127.0.0.1 }
acme_client_port="43718"

RELAYD_HEADER

  # Add backend tables for each app
  for app in "${(@k)app_ports}"; do
    port="${app_ports[$app]}"
    cat >> "/tmp/relayd.conf" << BACKEND_TABLE
table <${app}_backend> { 127.0.0.1 }
${app}_port="$port"

BACKEND_TABLE
  done

  cat >> "/tmp/relayd.conf" << HTTP_PROTOCOL
http protocol "filter_challenge" {
  pass request path "/.well-known/acme-challenge/*" forward to <acme_client>
}

relay "http_relay" {
  listen on \$egress port 80  
  protocol "filter_challenge"
  forward to <acme_client> port \$acme_client_port
}

http protocol "rails" {
  match request header set "X-Forwarded-By" value "\$SERVER_ADDR:\$SERVER_PORT"
  match request header set "X-Forwarded-For" value "\$REMOTE_ADDR"
  match response header set "Strict-Transport-Security" value "max-age=31536000; includeSubDomains; preload"
  match response header set "X-Content-Type-Options" value "nosniff"
  match response header set "X-Frame-Options" value "SAMEORIGIN"
  match response header set "X-XSS-Protection" value "1; mode=block"
  http websockets
HTTP_PROTOCOL

  # Add domain->app routing
  for app in "${(@k)app_domains}"; do
    domains="${app_domains[$app]}"
    for domain in ${(s/ /)domains}; do
      echo "  pass request header \"Host\" value \"$domain\" forward to <${app}_backend>" >> "/tmp/relayd.conf"
      
      # Add subdomain routing
      subdomains="${all_domains[$domain]}"
      if [[ -n "$subdomains" ]]; then
        for sub in ${(s/ /)subdomains}; do
          echo "  pass request header \"Host\" value \"$sub.$domain\" forward to <${app}_backend>" >> "/tmp/relayd.conf"
        done
      fi
    done
    
    # Add TLS keypair
    primary_domain=$(echo "${app_domains[$app]}" | cut -d" " -f1)
    echo "  tls keypair \"$primary_domain\"" >> "/tmp/relayd.conf"
  done

  cat >> "/tmp/relayd.conf" << HTTPS_RELAY
}

relay "https_relay" {
  listen on \$egress port 443 tls
  protocol "rails"
HTTPS_RELAY

  for app in "${(@k)app_ports}"; do
    echo "  forward to <${app}_backend> port \$${app}_port" >> "/tmp/relayd.conf"
  done

  echo "}" >> "/tmp/relayd.conf"
  
  if doas relayd -n -f "/tmp/relayd.conf"; then
    doas mv "/tmp/relayd.conf" /etc/relayd.conf
    doas rcctl enable relayd
    log "relayd configured successfully"
  else
    log "Error: Invalid relayd configuration"
    exit 1
  fi
}

setup_applications() {
  log "Setting up Rails applications..."
  
  for app in "${(@k)app_ports}"; do
    if ! id "$app" >/dev/null 2>&1; then
      doas useradd -m -G www -s /bin/ksh "$app"
      log "Created user: $app"
    fi
    
    app_dir="/home/$app/app"
    doas mkdir -p "$app_dir"/{public,config,log,tmp}
    
    # Database setup
    db_pass=$(openssl rand -hex 16)
    doas -u _postgresql psql -U postgres << SQL_SETUP
CREATE ROLE ${app}_user LOGIN PASSWORD '$db_pass';
CREATE DATABASE ${app}_production OWNER ${app}_user;
GRANT ALL PRIVILEGES ON DATABASE ${app}_production TO ${app}_user;
SQL_SETUP
    
    # Environment file using cat + heredoc
    cat > "/tmp/${app}_env" << ENV_FILE
RAILS_ENV=production
SECRET_KEY_BASE=$(openssl rand -hex 64)
DATABASE_URL=postgresql://${app}_user:$db_pass@localhost/${app}_production
REDIS_URL=redis://localhost:6379/0
ENV_FILE
    
    doas mv "/tmp/${app}_env" "$app_dir/.env"
    doas chown "$app:www" "$app_dir/.env"
    doas chmod 600 "$app_dir/.env"
    
    # Ruby config.ru using cat + heredoc (readable multiline over terse)
    cat > "/tmp/${app}_config.ru" << 'RUBY_CONFIG'
# frozen_string_literal: true

require "bundler/setup"

# Simple Rack application for demonstration
class SimpleApp
  def initialize(app_name)
    @app_name = app_name
  end

  def call(env)
    request = Rack::Request.new(env)
    host = request.host
    
    status = 200
    headers = { "Content-Type" => "text/html" }
    body = build_response(host)
    
    [status, headers, [body]]
  end

  private

  def build_response(host)
    <<~HTML
      <!DOCTYPE html>
      <html lang="en">
      <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>#{@app_name}</title>
      </head>
      <body>
        <h1>#{@app_name.capitalize} Application</h1>
        <p>Host: #{host}</p>
        <p>Status: Running</p>
        <p>Environment: #{ENV['RAILS_ENV']}</p>
      </body>
      </html>
    HTML
  end
end

run SimpleApp.new("APP_NAME_PLACEHOLDER")
RUBY_CONFIG
    
    # Replace placeholder with actual app name
    sed "s/APP_NAME_PLACEHOLDER/$app/g" "/tmp/${app}_config.ru" > "/tmp/${app}_config_final.ru"
    doas mv "/tmp/${app}_config_final.ru" "$app_dir/config.ru"
    rm "/tmp/${app}_config.ru"
    
    port="${app_ports[$app]}"
    
    # rc.d service script
    cat > "/tmp/${app}_rc" << RC_SCRIPT
#!/bin/ksh

daemon_user="$app"
daemon_execdir="$app_dir"
daemon_flags="--config $app_dir/config.ru --bind http://127.0.0.1:$port"
daemon="/usr/local/bin/falcon"

. /etc/rc.d/rc.subr

rc_bg=YES
rc_usercheck=YES

rc_start() {
    rc_exec "cd \$daemon_execdir && source .env && \$daemon \$daemon_flags"
}

rc_cmd \$1
RC_SCRIPT
    
    doas mv "/tmp/${app}_rc" "/etc/rc.d/$app"
    doas chmod +x "/etc/rc.d/$app"
    doas chown -R "$app:www" "$app_dir"
    doas rcctl enable "$app"
    
    log "Application $app configured on port $port"
  done
}

obtain_certificates() {
  log "Obtaining SSL certificates..."
  
  for domain in "${(@k)all_domains}"; do
    log "Requesting certificate for $domain..."
    if ! doas timeout 120 acme-client -v "$domain"; then
      log "Warning: Certificate request failed for $domain, continuing..."
    else
      log "Certificate obtained for $domain"
    fi
    sleep 2
  done
}

start_services() {
  log "Starting services..."
  
  # Start Redis
  doas rcctl enable redis
  doas rcctl start redis
  
  # Start Rails applications
  for app in "${(@k)app_ports}"; do
    doas rcctl start "$app"
    log "Started $app service"
  done
  
  # Start relayd
  doas rcctl start relayd
  log "Started relayd"
}

setup_cron() {
  log "Setting up certificate renewal..."
  
  # Create renewal script
  cat > "/tmp/renew_certs.sh" << RENEWAL_SCRIPT
#!/bin/ksh
for domain in $(ls /etc/ssl/*.crt | sed 's|/etc/ssl/||g; s|.crt||g'); do
  acme-client "\$domain" && rcctl reload relayd
done
RENEWAL_SCRIPT
  
  doas mv "/tmp/renew_certs.sh" /usr/local/bin/renew_certs.sh
  doas chmod +x /usr/local/bin/renew_certs.sh
  
  # Add to crontab (weekly renewal check)
  (doas crontab -l 2>/dev/null | grep -v renew_certs; echo "0 2 * * 0 /usr/local/bin/renew_certs.sh") | doas crontab -
  
  log "Certificate renewal configured"
}

main() {
  log "Starting OpenBSD Rails server setup..."
  log "Total domains to configure: ${#all_domains[@]}"
  log "Total applications: ${#app_ports[@]}"
  
  install_packages
  setup_postgresql
  setup_pf
  setup_nsd
  setup_acme
  setup_httpd
  obtain_certificates
  setup_relayd
  setup_applications
  start_services
  setup_cron
  
  log "Setup completed successfully!"
  log ""
  log "Configured applications:"
  for app in "${(@k)app_ports}"; do
    port="${app_ports[$app]}"
    domains="${app_domains[$app]}"
    log "  $app (port $port): $domains"
  done
  
  log ""
  log "Total configured:"
  log "  - Domains: ${#all_domains[@]}"
  log "  - Applications: ${#app_ports[@]}"
  log "  - DNS zones: ${#all_domains[@]}"
  log ""
  log "Services status:"
  doas rcctl check postgresql redis nsd httpd relayd pf
  
  log "Setup complete. All services should be running."
}

main "$@"
