#!/usr/bin/env zsh
# OpenBSD Rails Infrastructure v226.0.0
# Simplified, working deployment based on proven setup

set -euo pipefail

# Constants
readonly VERSION="226.0.0"
readonly MAIN_IP="185.52.176.18"
readonly BACKUP_NS="194.63.248.53"
readonly LOG_DIR="/var/log/rails"
readonly DEPLOY_BASE="/var/rails"

# Create log directory
mkdir -p "$LOG_DIR"

# Logging
log() {
  local level="${1:-INFO}"
  shift
  printf '[%s] %s: %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$level" "$*" | tee -a "$LOG_DIR/deploy.log"
}

error() {
  log "ERROR" "$*"
  exit 1
}

warn() {
  log "WARN" "$*"
}

# Domain mappings (44 domains)
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

# Validation
[[ $EUID -eq 0 ]] || error "Must run with doas/root"
[[ "$(uname -s)" == "OpenBSD" ]] || error "Must run on OpenBSD"

# TLS certificates
setup_tls() {
  log "INFO" "Setting up TLS certificates..."

  mkdir -p /var/www/acme /etc/acme /etc/ssl/private

  # Generate account key (RSA for compatibility)
  if [[ ! -f /etc/acme/letsencrypt-privkey.pem ]]; then
    openssl genrsa 4096 > /etc/acme/letsencrypt-privkey.pem
  fi

  # acme-client configuration
  cat > /etc/acme-client.conf << 'EOF'
authority letsencrypt {
  api url "https://acme-v02.api.letsencrypt.org/directory"
  account key "/etc/acme/letsencrypt-privkey.pem"
}
EOF

  for domain in "${(@k)all_domains}"; do
    if [[ -n "${all_domains[$domain]}" ]]; then
      # Domain with subdomains
      local alt_names=""
      for sub in ${(s/ /)all_domains[$domain]}; do
        alt_names="$alt_names $sub.$domain"
      done
      cat >> /etc/acme-client.conf << EOF
domain "$domain" {
  domain key "/etc/ssl/private/$domain.key" rsa
  domain full chain certificate "/etc/ssl/$domain.crt"
  sign with letsencrypt
  challengedir "/var/www/acme"
  alternative names { www.$domain$alt_names }
}
EOF
    else
      # Domain without subdomains
      cat >> /etc/acme-client.conf << EOF
domain "$domain" {
  domain key "/etc/ssl/private/$domain.key" rsa
  domain full chain certificate "/etc/ssl/$domain.crt"
  sign with letsencrypt
  challengedir "/var/www/acme"
}
EOF
    fi
  done

  # httpd for ACME challenges
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
    block return 302 "https://\$HTTP_HOST\$REQUEST_URI"
  }
}
EOF

  rcctl enable httpd
  rcctl restart httpd

  # Obtain certificates for all domains
  log "INFO" "Obtaining Let's Encrypt certificates (this may take a while)..."
  local cert_count=0
  local cert_failed=0

  for domain in "${(@k)all_domains}"; do
    log "INFO" "Requesting certificate for $domain..."
    if acme-client -v "$domain" 2>&1 | tee -a "$LOG_DIR/acme-$domain.log"; then
      log "INFO" "Certificate obtained for $domain"
      cert_count=$((cert_count + 1))
    else
      warn "Certificate failed for $domain - DNS may not be propagated yet"
      cert_failed=$((cert_failed + 1))
    fi
  done

  log "INFO" "TLS setup complete: $cert_count succeeded, $cert_failed failed"
}

# relayd load balancer with TLS
setup_relayd() {
  log "INFO" "Configuring relayd..."

  # Build table definitions
  cat > /etc/relayd.conf << 'EOF'
# Tables for each Rails app backend
EOF

  for app_port in "${(@k)app_domains}"; do
    app="${app_port%:*}"
    cat >> /etc/relayd.conf << EOF
table <${app}_servers> { 127.0.0.1 }
EOF
  done

  # HTTP protocol with security headers
  cat >> /etc/relayd.conf << 'EOF'

http protocol "rails" {
  match request header append "X-Forwarded-For" value "\$REMOTE_ADDR"
  match request header set "X-Forwarded-Proto" value "https"
  match response header set "Strict-Transport-Security" value "max-age=31536000"
  match response header set "X-Frame-Options" value "DENY"
  match response header set "X-Content-Type-Options" value "nosniff"
  http websockets
  tcp { nodelay, sack, socket buffer 65536 }
EOF

  # Add TLS keypairs for domains that have certificates
  for domain in "${(@k)all_domains}"; do
    if [[ -f "/etc/ssl/$domain.crt" ]]; then
      print "  tls keypair \"$domain\"" >> /etc/relayd.conf
    fi
  done

  cat >> /etc/relayd.conf << 'EOF'
}

EOF

  # Main relay - for now just forwards to brgen
  # TODO: Add host-based routing when Rails apps are deployed
  cat >> /etc/relayd.conf << 'EOF'
relay "rails" {
  listen on * port 443 tls
  protocol "rails"
  forward to <brgen_servers> port 10001 check tcp
}
EOF

  rcctl enable relayd
  if rcctl check relayd >/dev/null 2>&1; then
    rcctl reload relayd || rcctl restart relayd
  else
    rcctl start relayd
  fi

  log "INFO" "relayd configured"
}

# PF firewall
setup_firewall() {
  log "INFO" "Configuring PF firewall..."

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

  log "INFO" "Firewall configured"
}

# Main execution
main() {
  log "INFO" "Starting OpenBSD Rails Infrastructure deployment v$VERSION"

  setup_firewall
  setup_tls
  setup_relayd

  log "INFO" "Deployment complete!"
  log "INFO" "Next steps:"
  log "INFO" "  1. Check certificate status: ls -la /etc/ssl/*.crt"
  log "INFO" "  2. Deploy Rails applications to /home/*/app/"
  log "INFO" "  3. Start Rails app services: rcctl start *_rails"
}

case "${1:-}" in
  --help)
    cat << EOF
OpenBSD Rails Infrastructure v$VERSION

Usage: doas zsh openbsd_v2.sh

Configures:
- PF firewall with DDoS protection
- Let's Encrypt TLS certificates for 44 domains
- relayd for TLS termination and load balancing
- httpd for ACME challenges

Prerequisites:
- OpenBSD 7.x
- Root access
- Domains pointing to $MAIN_IP
EOF
    ;;
  *)
    main
    ;;
esac
