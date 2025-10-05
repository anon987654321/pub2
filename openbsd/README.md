# OpenBSD Rails Infrastructure v226.0.0

Simple, secure hosting for dozens of domains on OpenBSD. One script sets up everything: TLS certificates, firewall, load balancing. No fuss.

## What You Get

```
Internet → PF Firewall → relayd (handles HTTPS) → Your Rails Apps
                      ↘ httpd (for Let's Encrypt)
```

**44 domains, 7 applications, runs forever.**

- **TLS**: Free certificates from Let's Encrypt
- **Security**: Firewall blocks bad actors automatically  
- **Speed**: Fast load balancer with smart caching
- **Simple**: Everything in one script

## Your Domains

Cities across Europe and North America:

```
brgen.no       → markedsplass playlist dating tv takeaway maps
oshlo.no       → markedsplass playlist dating tv takeaway maps
lndon.uk       → marketplace playlist dating tv takeaway maps
newyrk.us      → marketplace playlist dating tv takeaway maps
pub.attorney   → legal services
bsdports.org   → BSD packages
```

**7 Apps on Different Ports**:
- brgen:10001 → 35+ city domains
- pubattorney:10002 → legal services
- bsdports:10003 → BSD ports
- hjerterom:10004 → Norwegian platform
- privcam:10005 → streaming
- amber:10006 → general app
- blognet:10007 → blog network

## Quick Start

```bash
# Copy script to your OpenBSD server
scp openbsd.sh user@your-server:/tmp/

# SSH in and run it
ssh user@your-server
doas zsh /tmp/openbsd.sh
```

That's it. Takes about 10 minutes depending on how many domain certificates succeed.

## What You Need

- OpenBSD 7.x server with root access
- Public IP address
- Your domains pointing to that IP
- About 2GB RAM and 10GB disk

## What Happens

The script sets up:

1. **Firewall** - Blocks attacks, allows web traffic
2. **TLS Certificates** - Gets HTTPS certificates for all your domains
3. **Load Balancer** - Routes traffic to your apps with security headers

Everything logs to `/var/log/rails/deploy.log` so you can see what's happening.

## After It Runs

**Check what worked:**
```bash
ls -la /etc/ssl/*.crt                 # See which certificates you got
tail -f /var/log/rails/deploy.log     # Watch the logs
```

**Upload your Rails apps:**
```bash
# Put your code in /home/APP/app/
# The script will make the users and folders
```

**Test it:**
```bash
curl -I https://yourdomain.com
```

## File Locations

```
/etc/httpd.conf          # Web server for Let's Encrypt
/etc/relayd.conf         # Load balancer config
/etc/pf.conf             # Firewall rules
/etc/acme-client.conf    # TLS certificate settings
/var/log/rails/          # All the logs
```

## Security Built In

- Only lets in web traffic and SSH
- Bans people who try too many connections
- Forces HTTPS for everything
- Stops common attacks automatically
- Each app runs as its own user

## If Something Breaks

**Check services:**
```bash
rcctl ls on              # What's running
rcctl check httpd        # Is httpd ok
rcctl check relayd       # Is relayd ok
```

**Read logs:**
```bash
tail -f /var/log/messages
tail -f /var/log/rails/deploy.log
```

**Test individual domains:**
```bash
acme-client -v yourdomain.com    # Try getting certificate again
```

## DNSSEC Setup (Optional but Recommended)

DNSSEC adds cryptographic authentication to DNS, preventing DNS hijacking and cache poisoning attacks. This is separate from the TLS certificates managed by `openbsd.sh`.

**What you need:**
- NSD authoritative DNS server running
- Zone files in `/var/nsd/zones/`
- Access to your domain registrar to submit DS records

**Recommended approach:**
1. Use **ECDSAP256SHA256** algorithm (modern, efficient)
2. Enable **NSEC3** with SHA-256 for authenticated denial of existence
3. Set key validity to **30 days** for regular rotation
4. Add **CAA records** to control which CAs can issue certificates
5. Automate key rollover with **monthly.local**

**Tools:**
- `ldns-utils` - Zone signing utilities (`pkg_add ldns-utils`)
- `ldnscripts` - Automation framework for key management (https://framagit.org/22decembre/ldnscripts)

**Basic workflow:**
1. Generate DNSSEC keys for your domain
2. Add CAA records to unsigned zone
3. Sign zone with `ldns-signzone`
4. Deploy signed zone to NSD
5. Extract DS record and submit to registrar
6. Verify with `dig +dnssec yourdomain.com`

**Key rollover automation:**
Create `/etc/monthly.local` to rotate keys automatically, preventing expiration and maintaining chain of trust.

See master.json `standards.openbsd_deployment.dnssec_optional` for complete implementation details.

## Keeping It Running

Certificates renew themselves automatically. The script is safe to run again if you need to add domains or fix something - it won't break what's already working.

System updates:
```bash
doas pkg_add -u          # Update packages
doas syspatch            # Security patches
```

---

Simple infrastructure that just works.

## Extra Security for Rails Apps

Your Rails apps can use OpenBSD's security features to lock themselves down even more:

```ruby
# In config/falcon.rb
require 'pledge'

# Only let the app see these folders
Pledge.unveil(Dir.pwd => 'r', :gem => 'r', '/tmp' => 'rwc')
Pledge.unveil(nil, nil)  # Lock it

# Only allow these system operations
Pledge.pledge('stdio inet rpath wpath cpath unix dns recvfd sendfd')
```

If someone hacks your app, they're stuck in a sandbox.
