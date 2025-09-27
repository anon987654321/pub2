#!/usr/bin/env ksh
# OpenBSD Rails hosting - 40+ domains, 7 apps
# Direct and robust: DNS → Firewall → SSL → Apps → Done

set -euo pipefail

# Two constants that matter
readonly MAIN_IP="46.23.95.45"
readonly BACKUP_NS="194.63.248.53"

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

print "Setting up ${#all_domains[@]} domains across ${#app_domains[@]} apps..."

# DNS with DNSSEC
doas mkdir -p /var/nsd/zones/master /var/nsd/zones/keys

# Generate DNSSEC keys if needed (ECDSA as per research)
for domain in "${(@k)all_domains}"; do
  [[ -f "/var/nsd/zones/keys/$domain.zsk.key" ]] || {
    cd /var/nsd/zones/keys
    ldns-keygen -a ECDSAP256SHA256 -b 256 "$domain" > "$domain.zsk"
    ldns-keygen -k -a ECDSAP256SHA256 -b 256 "$domain" > "$domain.ksk"
  }
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
  
  # Sign zone with DNSSEC
  cd /var/nsd/zones/master
  ldns-signzone -n -p -s $(head -n 1000 /dev/urandom | sha256 | cut -b 1-16) \
    "$domain.zone" \
    "../keys/$domain.zsk.key" \
    "../keys/$domain.ksk.key"
  
  doas chown -R _nsd:_nsd /var/nsd/zones
done

# NSD configuration
cat > /var/nsd/etc/nsd.conf << 'EOF'
server:
  hide-version: yes
  verbosity: 1
  rrl-ratelimit: 200
  rrl-size: 1000000
  
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

doas rcctl enable nsd && doas rcctl restart nsd

# PF with rate limiting from research
doas tee /etc/pf.conf > /dev/null << 'EOF'
# Tables for rate limiting
table <bruteforce> persist
table <ratelimit> persist

# Settings
set block-policy drop
set skip on lo
set limit states 500000
set timeout tcp.established 3600
set syncookies adaptive (start 25%, end 12%)

# Scrub
match in all scrub (no-df random-id max-mss 1440)

# Default
block all

# Outbound
pass out all

# SSH with protection
pass in proto tcp to port 22 flags S/SA synproxy state \
  (source-track rule, max-src-conn 10, max-src-conn-rate 5/60, \
   overload <bruteforce> flush global)

# DNS
pass in proto { tcp udp } to port 53

# Web with DDoS protection
pass in proto tcp to port { 80 443 } flags S/SA synproxy state \
  (source-track global, max-src-states 1000, max-src-conn 100, \
   max-src-conn-rate 50/30, overload <ratelimit> flush global)

# Apps
pass in proto tcp to port 10001:10007

# relayd anchor
anchor "relayd/*"
EOF
doas pfctl -f /etc/pf.conf && doas rcctl enable pf

# SSL certificates
doas mkdir -p /var/www/acme /etc/acme /etc/ssl/private

[[ -f /etc/acme/letsencrypt-privkey.pem ]] || \
  doas openssl ecparam -genkey -name prime256v1 | doas tee /etc/acme/letsencrypt-privkey.pem > /dev/null

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
  [[ -n "${all_domains[$domain]}" ]] && {
    print -n "  alternative names { www.$domain "
    for sub in ${(s/ /)all_domains[$domain]}; do print -n "$sub.$domain "; done
    print "}"
  } >> /etc/acme-client.conf || print "}" >> /etc/acme-client.conf
done

# httpd for ACME challenges and static files
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
doas rcctl enable httpd && doas rcctl restart httpd

# Get certificates
for domain in "${(@k)all_domains}"; do
  doas acme-client -v "$domain" || print "Warning: $domain cert failed"
done

# relayd for load balancing and TLS termination
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

# HTTP protocol with Rails headers
http protocol "rails" {
  match request header append "X-Forwarded-For" value "$REMOTE_ADDR"
  match request header set "X-Forwarded-Proto" value "https"
  match response header set "Strict-Transport-Security" value "max-age=31536000"
  
  # WebSocket for Action Cable
  http websockets
  
  tcp { nodelay, sack, socket buffer 65536, backlog 1000 }
  
  # TLS settings with multiple keypairs
EOF

for domain in "${(@k)all_domains}"; do
  [[ -f "/etc/ssl/$domain.crt" ]] && \
    print "  tls keypair \"$domain\"" >> /etc/relayd.conf
done

cat >> /etc/relayd.conf << 'EOF'
  
  tls { no tlsv1.0, no tlsv1.1, ciphers "ECDHE+AESGCM:ECDHE+CHACHA20:DHE+AESGCM" }
}

# Main relay
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

doas rcctl enable relayd && doas rcctl restart relayd

# Install Ruby and dependencies
doas pkg_add -U ruby-3.3 postgresql-server redis node

# PostgreSQL
[[ -d /var/postgresql/data ]] || {
  doas install -d -o _postgresql -g _postgresql /var/postgresql/data
  doas -u _postgresql initdb -D /var/postgresql/data -U postgres -A scram-sha-256 -E UTF8
}
doas rcctl enable postgresql && doas rcctl start postgresql

# Redis
doas rcctl enable redis && doas rcctl start redis

# Create apps with proper service files
for app_port in "${(@k)app_domains}"; do
  app="${app_port%:*}"
  port="${app_port#*:}"
  
  # User creation (idempotent)
  id "$app" 2>/dev/null || doas useradd -m -G www -s /bin/ksh "$app"
  
  # App directory
  doas -u "$app" mkdir -p "/home/$app/app"
  
  # Database with generated password
  pass=$(openssl rand -hex 16)
  doas -u _postgresql psql -U postgres << SQL 2>/dev/null || true
CREATE ROLE ${app}_user LOGIN PASSWORD '$pass';
CREATE DATABASE ${app}_production OWNER ${app}_user;
SQL
  
  # Save credentials
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
  doas tee "/etc/rc.d/${app}_rails" > /dev/null << EOF
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
  
  doas chmod +x "/etc/rc.d/${app}_rails"
  doas rcctl enable "${app}_rails"
  doas rcctl start "${app}_rails"
done

# Cron for certificate renewal
(crontab -l 2>/dev/null | grep -v acme-client; \
 echo "0 0 * * * for d in ${(@k)all_domains}; do acme-client \$d; done") | crontab -

# Login.conf for app limits
doas tee -a /etc/login.conf > /dev/null << 'EOF'

railsapp:\
  :openfiles-max=4096:\
  :datasize-max=2G:\
  :maxproc-max=256:\
  :tc=daemon:
EOF

doas cap_mkdb /etc/login.conf

# Final status
print "\n=== Deployment Complete ==="
print "Domains configured: ${#all_domains[@]}"
print "Apps running: ${#app_domains[@]}"
print "Services enabled: nsd httpd relayd postgresql redis"
doas rcctl ls on
