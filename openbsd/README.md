# OpenBSD Rails Infrastructure v225.0.0

**The definitive deployment for hosting dozens of domains on OpenBSD.** This is infrastructure as philosophy: secure by design, minimal by nature, bulletproof by execution. One script deploys everything—DNS with DNSSEC, TLS termination, Rails applications, reverse DNS—creating a fortress that scales from startups to empires.

Born from the Unix principle that each tool should do one thing well, this deployment orchestrates OpenBSD's native strengths into a cohesive platform. No Docker overhead. No Kubernetes complexity. Just OpenBSD doing what it does best: running forever.

**Now with**: Structured JSON logging, zsh-native patterns, evidence-based validation, master.json v225.0.0 compliance.

## Architecture

```
Internet → PF → relayd (TLS) → Rails Apps (Falcon)
         ↘ httpd (ACME)
         
DNS: NSD + DNSSEC → Master + Slave
PTR: OpenBSD Amsterdam API
```

**40+ domains, 7 applications, infinite possibilities.**

- **DNS**: NSD with DNSSEC (ECDSA P-256)
- **TLS**: LibreSSL with Let's Encrypt
- **Apps**: Falcon servers behind relayd
- **Security**: PF with DDoS protection
- **Data**: PostgreSQL + Redis

## Domains

**Geographic Coverage**: Norway to New York, Bergen to Berlin.

```
brgen.no       → markedsplass playlist dating tv takeaway maps
oshlo.no       → markedsplass playlist dating tv takeaway maps
lndon.uk       → marketplace playlist dating tv takeaway maps
newyrk.us      → marketplace playlist dating tv takeaway maps
pub.attorney   → legal services
bsdports.org   → BSD packages
```

**7 Applications**:
- brgen:10001 → 35+ city domains
- pubattorney:10002 → legal services  
- bsdports:10003 → BSD ports
- hjerterom:10004 → Norwegian platform
- privcam:10005 → streaming
- amber:10006 → general app
- blognet:10007 → blog network

## Installation

```bash
git clone https://github.com/anon987654321/pub2.git
cd pub2/openbsd
doas ksh openbsd.sh
```

**That's it.** The script is idempotent—run it again if interrupted.

## Prerequisites

- OpenBSD 7.x with root access
- Public IP and domain control
- 2GB RAM, 10GB disk

## What Happens

1. **Environment**: Verify OpenBSD, connectivity, OpenBSD Amsterdam VM
2. **DNS**: NSD with DNSSEC keys, signed zones
3. **Firewall**: PF with rate limiting, DDoS protection
4. **TLS**: acme-client with LibreSSL certificates
5. **Web**: httpd for ACME, relayd for load balancing
6. **Data**: PostgreSQL and Redis setup
7. **Apps**: Rails applications with Falcon
8. **PTR**: Reverse DNS (OpenBSD Amsterdam only)
9. **Maintenance**: Cron jobs, limits, monitoring

## After Deployment

**DNS**: Point your domains to your server IP. Submit DS records from `/var/nsd/zones/keys/*.ds` to your registrar.

**Apps**: Upload Rails code to `/home/APP/app/`. The script creates users, databases, and service scripts.

**Monitoring**:
```bash
rcctl ls on                    # Services
tail -f /var/log/messages     # Logs
curl -I https://yourdomain.com # Test
```

## File Structure

```
/var/nsd/zones/               # DNS zones + DNSSEC keys
/etc/acme-client.conf         # TLS certificates
/etc/{httpd,pf,relayd}.conf   # Core services
/home/APP/app/                # Rails applications
```

## Security Features

- **DNSSEC**: Full chain of trust
- **TLS 1.2+**: Modern ciphers only
- **Rate Limiting**: 100 connections, 50/30 rate
- **DDoS Protection**: Automatic blocking
- **Isolation**: Separate users per app

## Troubleshooting

**DNS**: `dig @127.0.0.1 domain.com`
**TLS**: `acme-client -v domain.com`
**Apps**: `rcctl check APP_rails`
**PTR**: OpenBSD Amsterdam VMs only

## Maintenance

- Certificates renew automatically via cron
- DNSSEC keys should rotate annually
- System updates: `pkg_add -u && syspatch`

---

Infrastructure that thinks in decades, not deployment cycles.

**Author**: anon987654321  
**Repository**: https://github.com/anon987654321/pub2/tree/main/openbsd

## pledge(2) and unveil(2) Security

Falcon servers can run with OpenBSD's native security restrictions:

- **pledge gem**: `gem "pledge", "~> 1.2.0"` (by Jeremy Evans)
- **unveil**: Restrict filesystem access to specific paths before accepting requests
- **pledge**: Restrict system calls after initialization

Example usage in config/falcon.rb:
```ruby
require 'pledge'

# Unveil paths FIRST (app, gems, /tmp, sockets, certs)
Pledge.unveil(Dir.pwd => 'r', :gem => 'r', '/tmp' => 'rwc')
Pledge.unveil(nil, nil)  # Lock

# Then pledge (stdio inet rpath wpath cpath unix dns)
Pledge.pledge('stdio inet rpath wpath cpath unix dns recvfd sendfd')
```

Defense-in-depth: even if Rails is compromised, attacker is sandboxed.
