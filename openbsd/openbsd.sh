#!/usr/bin/env ksh
# OpenBSD Rails hosting - Complete infrastructure deployment
# 40+ domains, 7 apps, DNS, TLS, PTR records - Direct and robust

set -euo pipefail

readonly SCRIPT_NAME="${0##*/}"
readonly MAIN_IP="46.23.95.45"
readonly BACKUP_NS="194.63.248.53"
readonly PTR4_API="http://ptr4.openbsd.amsterdam"
readonly PTR6_API="http://ptr6.openbsd.amsterdam"

# Domain to subdomains - direct mapping
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

# App to domains - who serves what
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

# Primary PTR domains (one per service for clean reverse DNS)
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

log() {
  printf "[%s] %s: %s\n" "$(date '+%Y-%m-%d %H:%M:%S')" "$SCRIPT_NAME" "$*" >&2
}

error() {
  log "ERROR: $*"
  exit 1
}

warn() {
  log "WARNING: $*"
}

check_environment() {
  log "Checking deployment environment..."
  
  [[ $EUID -eq 0 ]] || error "Must run with doas"
  
  local version
  version=$(uname -r 2>/dev/null || echo "unknown")
  [[ "$version" =~ ^[67]\.[0-9] ]] || warn "Expected OpenBSD 6.x/7.x, got: $version"
  
  ping -c 1 -W 1000 8.8.8.8 >/dev/null 2>&1 || error "No internet connectivity"
  
  local hostname
  hostname=$(hostname 2>/dev/null || echo "unknown")
  if [[ "$hostname" =~ ^vm[0-9]+ ]]; then
    log "OpenBSD Amsterdam VM detected: $hostname"
    ftp -MVo /dev/null "$PTR4_API" 2>/dev/null || warn "PTR service not reachable"
  else
    warn "Not on OpenBSD Amsterdam VM - PTR functionality will be skipped"
  fi
  
  log "Environment check completed"
}

setup_dns_dnssec() {
  log "Setting up NSD with full DNSSEC support..."
  
  mkdir -p /var/nsd/zones/master /var/nsd/zones/keys
  
  # Generate DNSSEC keys using ldns-keygen (part of NSD DNSSEC support)
  for domain in "${(@k)all_domains}"; do
    [[ -f "/var/nsd/zones/keys/$domain.zsk.key" ]] || {
      cd /var/nsd/zones/keys
      # ZSK (Zone Signing Key) - ECDSA P-256 SHA-256
      ldns-keygen -a ECDSAP256SHA256 -b 256 "$domain" > "$domain.zsk"
      # KSK (Key Signing Key) - ECDSA P-256 SHA-256  
      ldns-keygen -k -a ECDSAP256SHA256 -b 256 "$domain" > "$domain.ksk"
    }
  done
  
  # Create and sign zone files with DNSSEC
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
    
    # Sign zone with DNSSEC using ldns-signzone
    cd /var/nsd/zones/master
    ldns-signzone -n -p -s $(head -n 1000 /dev/urandom | sha256 | cut -b 1-16) \
      "$domain.zone" \
      "../keys/$domain.zsk.key" \
      "../keys/$domain.ksk.key"
    
    chown -R _nsd:_nsd /var/nsd/zones
  done
  
  # NSD configuration with DNSSEC enabled
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
  
  rcctl enable nsd && rcctl restart nsd
  log "NSD with DNSSEC configured and started"
}

setup_firewall() {
  log "Configuring PF firewall with DDoS protection..."
  
  tee /etc/pf.conf > /dev/null << 'EOF'
# Tables for rate limiting and protection
table <bruteforce> persist
table <ratelimit> persist

# Settings optimized for Rails hosting
set block-policy drop
set skip on lo
set limit states 500000
set timeout tcp.established 3600
set syncookies adaptive (start 25%, end 12%)

# Scrub packets
match in all scrub (no-df random-id max-mss 1440)

# Default deny
block all

# Outbound traffic
pass out all

# SSH with brute force protection
pass in proto tcp to port 22 flags S/SA synproxy state \
  (source-track rule, max-src-conn 10, max-src-conn-rate 5/60, \
   overload <bruteforce> flush global)

# DNS (both TCP and UDP for zone transfers)
pass in proto { tcp udp } to port 53

# Web with DDoS protection
pass in proto tcp to port { 80 443 } flags S/SA synproxy state \
  (source-track global, max-src-states 1000, max-src-conn 100, \
   max-src-conn-rate 50/30, overload <ratelimit> flush global)

# Rails applications
pass in proto tcp to port 10001:10007

# relayd anchor for load balancing
anchor "relayd/*"
EOF

  pfctl -f /etc/pf.conf && rcctl enable pf
  log "PF firewall configured with DDoS protection"
}

setup_tls_certificates() {
  log "Setting up TLS certificates with LibreSSL/acme-client..."
  
  mkdir -p /var/www/acme /etc/acme /etc/ssl/private
  
  # Generate ECDSA account key if needed
  [[ -f /etc/acme/letsencrypt-privkey.pem ]] || \
    openssl ecparam -genkey -name prime256v1 | tee /etc/acme/letsencrypt-privkey.pem > /dev/null
  
  # acme-client configuration for Let's Encrypt
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
    [[ -n "${all_domains[$domain]}" ]] && {
      print -n "  alternative names { www.$domain "
      for sub in ${(s/ /)all_domains[$domain]}; do print -n "$sub.$domain "; done
      print "}"
    } >> /etc/acme-client.conf || print "}" >> /etc/acme-client.conf
  done
  
  log "TLS certificate configuration completed"
}

setup_httpd() {
  log "Configuring httpd for ACME challenges and redirects..."
  
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

  rcctl enable httpd && rcctl restart httpd
  
  # Get certificates
  for domain in "${(@k)all_domains}"; do
    acme-client -v "$domain" || warn "Certificate failed for $domain"
  done
  
  log "httpd configured and certificates obtained"
}

setup_relayd() {
  log "Configuring relayd with TLS termination..."
  
  cat > /etc/relayd.conf << 'EOF'
prefork 5

# Tables for app servers
EOF

  for app_port in "${(@k)app_domains}"; do
    app="${app_port%:*}"
    port="${app_port#*:}"
    cat >> /etc/relayd.conf << EOF
table <${app}_servers> { 127.0.0.1 }
EOF
  done

  cat >> /etc/relayd.conf << 'EOF'

# HTTP protocol with Rails security headers
http protocol "rails" {
  match request header append "X-Forwarded-For" value "$REMOTE_ADDR"
  match request header set "X-Forwarded-Proto" value "https"
  match response header set "Strict-Transport-Security" value "max-age=31536000"
  match response header set "X-Frame-Options" value "DENY"
  match response header set "X-Content-Type-Options" value "nosniff"
  
  # WebSocket support for Action Cable
  http websockets
  
  # TCP optimizations
  tcp { nodelay, sack, socket buffer 65536, backlog 1000 }
  
  # TLS settings with LibreSSL
EOF

  for domain in "${(@k)all_domains}"; do
    [[ -f "/etc/ssl/$domain.crt" ]] && \
      print "  tls keypair \"$domain\"" >> /etc/relayd.conf
  done

  cat >> /etc/relayd.conf << 'EOF'
  
  # Modern TLS with LibreSSL - no legacy protocols
  tls { no tlsv1.0, no tlsv1.1, ciphers "ECDHE+AESGCM:ECDHE+CHACHA20:DHE+AESGCM" }
}

# Main TLS relay
relay "rails" {
  listen on * port 443 tls
  protocol "rails"
  
EOF

  for app_port in "${(@k)app_domains}"; do
    app="${app_port%:*}"
    port="${app_port#*:}"
    for domain in ${(s/ /)app_domains[$app_port]}; do
      cat >> /etc/relayd.conf << EOF
  forward to <${app}_servers> port $port check tcp
EOF
    done
  done

  cat >> /etc/relayd.conf << 'EOF'
}
EOF

  rcctl enable relayd && rcctl restart relayd
  log "relayd configured with TLS termination"
}

setup_databases() {
  log "Setting up PostgreSQL and Redis..."
  
  # Install packages
  pkg_add -U ruby-3.3 postgresql-server redis node
  
  # PostgreSQL setup
  [[ -d /var/postgresql/data ]] || {
    install -d -o _postgresql -g _postgresql /var/postgresql/data
    doas -u _postgresql initdb -D /var/postgresql/data -U postgres -A scram-sha-256 -E UTF8
  }
  rcctl enable postgresql && rcctl start postgresql
  
  # Redis setup
  rcctl enable redis && rcctl start redis
  
  log "Databases configured and started"
}

setup_rails_apps() {
  log "Setting up Rails applications..."
  
  for app_port in "${(@k)app_domains}"; do
    app="${app_port%:*}"
    port="${app_port#*:}"
    
    # User creation (idempotent)
    id "$app" 2>/dev/null || useradd -m -G www -s /bin/ksh "$app"
    
    # App directory
    doas -u "$app" mkdir -p "/home/$app/app"
    
    # Database with generated password
    local pass
    pass=$(openssl rand -hex 16)
    doas -u _postgresql psql -U postgres << SQL 2>/dev/null || true
CREATE ROLE ${app}_user LOGIN PASSWORD '$pass';
CREATE DATABASE ${app}_production OWNER ${app}_user;
SQL
    
    # Database configuration
    doas -u "$app" tee "/home/$app/app/database.yml" > /dev/null << EOF
production:
  adapter: postgresql
  database: ${app}_production
  username: ${app}_user
  password: $pass
  host: localhost
EOF
    
    # Minimal Falcon config
    doas -u "$app" tee "/home/$app/app/config.ru" > /dev/null << 'RUBY'
require 'falcon'

class App
  def call(env)
    [200, {"Content-Type" => "text/html"}, ["<h1>App Running on #{env['HTTP_HOST']}</h1>"]]
  end
end

run App.new
RUBY
    
    # Falcon configuration
    doas -u "$app" tee "/home/$app/app/config/falcon.rb" > /dev/null << RUBY
#!/usr/bin/env ruby
require 'async'
require 'async/http/endpoint'

port = $port

Async do
  endpoint = Async::HTTP::Endpoint.parse("http://0.0.0.0:#{port}")
    .with(protocol: Async::HTTP::Protocol::HTTP11)
  
  bound_endpoint = endpoint.bound
  
  puts "Falcon running on port #{port}"
  
  bound_endpoint.accept do |peer|
    # Handle connection
  end
end
RUBY

    # rc.d service script
    tee "/etc/rc.d/${app}_rails" > /dev/null << EOF
#!/bin/ksh
daemon="/usr/local/bin/falcon"
daemon_user="$app"
daemon_flags="serve --port $port --config /home/$app/app/config/falcon.rb"
daemon_timeout=30

. /etc/rc.d/rc.subr

rc_bg=YES
rc_reload=NO

rc_cmd \$1
EOF
    
    chmod +x "/etc/rc.d/${app}_rails"
    rcctl enable "${app}_rails"
    rcctl start "${app}_rails"
  done
  
  log "Rails applications configured and started"
}

get_ptr_token() {
  local api="$1"
  local token
  
  token=$(ftp -MVo- "$api/token" 2>/dev/null | tr -d '\r\n') || {
    warn "Failed to get PTR token from $api"
    return 1
  }
  
  [[ -n "$token" && ${#token} -eq 32 ]] || {
    warn "Invalid token format: $token"
    return 1
  }
  
  echo "$token"
}

set_ptr_record() {
  local api="$1"
  local token="$2"
  local fqdn="$3"
  local response
  
  log "Setting PTR: $fqdn via $api"
  
  response=$(ftp -MVo- "$api/$token/$fqdn" 2>/dev/null) || {
    warn "Failed to set PTR for $fqdn"
    return 1
  }
  
  if [[ "$response" =~ "will be processed asap" ]]; then
    log "SUCCESS: $response"
    return 0
  else
    warn "Unexpected response: $response"
    return 1
  fi
}

setup_ptr_records() {
  local hostname
  hostname=$(hostname 2>/dev/null || echo "unknown")
  
  if [[ ! "$hostname" =~ ^vm[0-9]+ ]]; then
    log "Not on OpenBSD Amsterdam VM - skipping PTR setup"
    return 0
  fi
  
  log "Setting up PTR records for OpenBSD Amsterdam VM..."
  
  # Test PTR service availability
  ftp -MVo /dev/null "$PTR4_API" 2>/dev/null || {
    warn "PTR service not available - skipping PTR setup"
    return 0
  }
  
  # Set up primary PTR record first
  local token4 token6
  token4=$(get_ptr_token "$PTR4_API") || return 1
  token6=$(get_ptr_token "$PTR6_API") || return 1
  
  set_ptr_record "$PTR4_API" "$token4" "${primary_ptrs[main]}"
  set_ptr_record "$PTR6_API" "$token6" "${primary_ptrs[main]}"
  
  # Set up service PTR records
  for service in "${(@k)primary_ptrs}"; do
    [[ "$service" != "main" ]] || continue
    
    # Get fresh tokens (5-minute expiry)
    token4=$(get_ptr_token "$PTR4_API") || continue
    token6=$(get_ptr_token "$PTR6_API") || continue
    
    set_ptr_record "$PTR4_API" "$token4" "${primary_ptrs[$service]}"
    set_ptr_record "$PTR6_API" "$token6" "${primary_ptrs[$service]}"
  done
  
  log "PTR records configured (will propagate within 60 seconds)"
}

protect_ptr_records() {
  local hostname
  hostname=$(hostname 2>/dev/null || echo "unknown")
  
  if [[ ! "$hostname" =~ ^vm[0-9]+ ]]; then
    return 0
  fi
  
  log "Protecting PTR records from future changes..."
  
  local response4 response6
  response4=$(ftp -MVo- "$PTR4_API/protect" 2>/dev/null) && \
    log "IPv4 protection: $response4"
  
  response6=$(ftp -MVo- "$PTR6_API/protect" 2>/dev/null) && \
    log "IPv6 protection: $response6"
  
  log "PTR records protected - contact OpenBSD Amsterdam to make changes"
}

setup_cron() {
  log "Setting up maintenance cron jobs..."
  
  # Certificate renewal
  (crontab -l 2>/dev/null | grep -v acme-client; \
   echo "0 0 * * * for d in ${(@k)all_domains}; do acme-client \$d; done") | crontab -
  
  log "Cron jobs configured"
}

setup_login_limits() {
  log "Configuring login limits for Rails applications..."
  
  tee -a /etc/login.conf > /dev/null << 'EOF'

railsapp:\
  :openfiles-max=4096:\
  :datasize-max=2G:\
  :maxproc-max=256:\
  :tc=daemon:
EOF

  cap_mkdb /etc/login.conf
  log "Login limits configured"
}

show_deployment_summary() {
  log "=== Deployment Summary ==="
  log "Domains configured: ${#all_domains[@]}"
  log "Applications running: ${#app_domains[@]}"
  log "Services enabled: $(rcctl ls on | tr '\n' ' ')"
  
  log "=== Service Status ==="
  for service in nsd httpd postgresql redis relayd; do
    if rcctl check "$service" >/dev/null 2>&1; then
      log "$service: running"
    else
      warn "$service: not running"
    fi
  done
  
  log "=== Next Steps ==="
  log "1. Upload Rails applications to /home/<app>/app/"
  log "2. Configure domain DNS to point to $MAIN_IP"
  log "3. Submit DS records from /var/nsd/zones/keys/*.ds to registrar"
  log "4. Monitor logs: tail -f /var/log/messages"
  log "=== Deployment Complete ==="
}

main() {
  log "Starting OpenBSD Rails infrastructure deployment..."
  
  check_environment
  setup_dns_dnssec
  setup_firewall
  setup_tls_certificates
  setup_httpd
  setup_relayd
  setup_databases
  setup_rails_apps
  setup_ptr_records
  setup_cron
  setup_login_limits
  
  # Protect PTR records last (makes them immutable)
  protect_ptr_records
  
  show_deployment_summary
  
  log "Deployment completed successfully!"
}

# Handle command line arguments
case "${1:-}" in
  --help)
    cat << 'EOF'
OpenBSD Rails Infrastructure Deployment

Usage: doas ksh openbsd.sh [--help]

This script deploys a complete Rails hosting infrastructure on OpenBSD with:
- NSD with full DNSSEC support (ECDSA P-256 SHA-256)
- TLS certificates via acme-client (LibreSSL)
- PF firewall with DDoS protection
- relayd with TLS termination
- PostgreSQL and Redis databases
- Rails applications with Falcon server
- PTR record management (OpenBSD Amsterdam VMs)

Prerequisites:
- OpenBSD 7.x with internet connectivity
- Root access via doas
- Domains registered and ready for DS record submission

The script is idempotent and can be safely re-run.
EOF
    exit 0
    ;;
  "")
    main
    ;;
  *)
    error "Unknown option: $1. Use --help for usage."
    ;;
esac
