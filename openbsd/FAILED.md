# Failed TLS Certificate Domains

Status as of 2025-10-04

## DNS Not Configured (NXDOMAIN - Domain doesn't resolve at all)

These domains return NXDOMAIN, meaning they either don't exist or have no DNS records configured:

- `reykjavk.is` - No DNS records
- `gteborg.se` - No DNS records
- `lsbon.pt` - No DNS records
- `newyrk.us` - No DNS records
- `chcago.us` - No DNS records
- `dtroit.us` - No DNS records
- `houstn.us` - No DNS records
- `dllas.us` - No DNS records
- `austn.us` - No DNS records
- `prtland.com` - No DNS records
- `mnneapolis.com` - No DNS records
- `hjerterom.no` - No DNS records
- `antibettingblog.com` - No DNS records
- `anticasinoblog.com` - No DNS records
- `antigamblingblog.com` - No DNS records

**Action:** These domains may need to be registered or have their invoices paid. No DNS records exist.

## Pointing to Wrong IP (185.134.245.113)

These domains resolve but point to `185.134.245.113` instead of our VPS at `185.52.176.18`:

- `mlan.it` → 185.134.245.113 (should be 185.52.176.18)
- `freehelp.legal` → 185.134.245.113 (should be 185.52.176.18)
- `privcam.no` → 185.134.245.113 (should be 185.52.176.18)
- `foball.no` → 185.134.245.113 (should be 185.52.176.18)
- `stacyspassion.com` → 185.134.245.113 (should be 185.52.176.18)

**Action:** Update DNS A records to point to `185.52.176.18`

## Pointing to Wrong IP (76.223.54.146)

- `amberapp.com` → 76.223.54.146 (should be 185.52.176.18)

**Action:** Update DNS A record to point to `185.52.176.18`

## Summary

- **Total failed:** 21 domains
- **NXDOMAIN (not registered/configured):** 15 domains
- **Wrong IP (185.134.245.113):** 5 domains
- **Wrong IP (76.223.54.146):** 1 domain

## Successfully Obtained Certificates

27 certificates were successfully obtained for domains properly pointing to 185.52.176.18:

✅ brgen.no, oshlo.no, trndheim.no, stvanger.no, trmso.no, stholm.se, mlmoe.se, hlsinki.fi, kobenhvn.dk, lndon.uk, mnchester.uk, brmingham.uk, edinbrgh.uk, glasgw.uk, lverpool.uk, amstrdam.nl, rottrdam.nl, utrcht.nl, brssels.be, zrich.ch, lchtenstein.li, frankfrt.de, mrseille.fr, lsangeles.com, bsdports.org, pub.attorney, foodielicio.us
