# OpenBSD Setup for Scalable Rails and Secure Email

This script configures OpenBSD 7.7 as a robust,
modular platform for Ruby on Rails applications and a single-user email service,
embodying the Unix philosophy of doing one thing well to power a focused,
secure system for hyperlocal platforms with DNSSEC.

## Setup Instructions

1. **Prerequisites**:
   - OpenBSD 7.7 installed on master (PowerPC Mac Mini) and slave (VM).
   - Directories (`/var/nsd`,
`/var/www/acme`,
`/var/postgresql/data`,
`/var/redis`,
`/var/vmail`) have correct ownership/permissions (e.g.,
`/var/www/acme` as `root:_httpd`,
755).
   - Rails apps (`brgen`,
`amber`,
`bsdports`) ready to upload to `/home/<app>/<app>` with `Gemfile` and `database.yml`.
   - Unprivileged user `gfuser` with `mutt` installed for email access.
   - Internet connectivity for package installation.
   - Domain (e.g., `brgen.no`) registered with Domeneshop.no, ready for DS records.

2. **Run the Script**:
   ```bash
   doas zsh openbsd.sh
   ```
   - `--resume`: Run after Stage 1 (DNS/certs).
   - `--mail`: Run after Stage 2 (services/apps) for email.
   - `--help`: Show usage.

3. **Stages**:
   - **Stage 1**: Installs `ruby-3.3.5`,
`ldns-utils`,
`postgresql-server`,
`redis`,
and `zap` using OpenBSD 7.7’s default `pkg_add`. Configures `ns.brgen.no` (46.23.95.45) as master nameserver with DNSSEC (ECDSAP256SHA256 keys,
signed zones),
allowing zone transfers to `ns.hyp.net` (194.63.248.53,
managed by Domeneshop.no) via TCP 53 and sending NOTIFY via UDP 53,
with `pf` permitting TCP/UDP 53 traffic on `ext_if` (vio0). Generates TLSA records for HTTPS services. Issues certificates via Let’s Encrypt. Pauses to let you upload Rails apps (`brgen`,
`amber`,
`bsdports`) to `/home/<app>/<app>` with `Gemfile` and `database.yml`. Press Enter to proceed,
then submit DS records from `/var/nsd/zones/master/*.ds` to Domeneshop.no. Test with `dig @46.23.95.45 brgen.no SOA`,
`dig @46.23.95.45 denvr.us A`,
`dig DS brgen.no +short`,
and `dig TLSA _443._tcp.brgen.no`. Wait for propagation (24–48 hours) before `--resume`. `ns.hyp.net` requires no local setup (configure slave separately).
   - **Stage 2**: Sets up PostgreSQL,
Redis,
PF firewall,
relayd with security headers,
and Rails apps with Falcon server. Logs go to `/var/log/messages`. Applies CSS micro-text (e.g.,
7.5pt) for app footer branding if applicable.
   - **Stage 3**: Configures OpenSMTPD for `bergen@pub.attorney`, accessible via `mutt` for `gfuser`.

4. **Verification**:
   - Services: `rcctl check nsd httpd postgresql redis relayd smtpd`.
   - DNS: `dig @46.23.95.45 brgen.no SOA`, `dig @46.23.95.45 denvr.us A`.
   - DNSSEC: `dig DS brgen.no +short`, `dig DNSKEY brgen.no +short`.
   - TLSA: `dig TLSA _443._tcp.brgen.no`.
   - Firewall: `doas pfctl -s rules` to confirm DNS and other rules.
   - Email: Check `/var/vmail/pub.attorney/bergen/new` as `gfuser` with `mutt`.
   - Logs: `tail -f /var/log/messages` for Rails app activity.