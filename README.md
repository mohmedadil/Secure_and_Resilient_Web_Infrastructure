# Hardened Web Server — Nginx + firewalld on RHEL 10

This is a lab project I built to get hands-on experience hardening a web server. It's designed to look and feel like something you'd actually see in production, with proper security practices baked in from the start.

## What I Built Here
- Set up a hardened Linux server from scratch on RHEL
- Locked down the firewall so only what's needed gets through
- Secured Nginx with proper headers and encryption
- Added fail2ban to automatically block brute-force attempts
- Wrote scripts to verify everything's working as intended

## What's Running
- **OS:** RHEL 10
- **Web Server:** Nginx
- **Firewall:** firewalld (configured for least privilege)
- **SSL:** Self-signed certificate (good enough for a lab)
- **Intrusion Prevention:** fail2ban

## How I Hardened This Thing

### Firewall
I stripped down firewalld to only allow what's actually needed: SSH, HTTP, HTTPS, and DHCPv6. Got rid of the default stuff that comes pre-enabled like Cockpit and NFS that nobody needs.

### Nginx
Disabled version headers so the server doesn't advertise what version of Nginx it's running. Added the standard security headers like `X-Frame-Options` and `X-Content-Type-Options`. Also forced HTTPS everywhere — anything coming in on port 80 gets redirected to 443.

### SSL/TLS
Generated a 2048-bit self-signed cert with OpenSSL. Locked it down to TLS 1.2 and 1.3, disabled the weak ciphers.

### Fail2ban
Set it up to watch SSH and Nginx logs. If someone tries to brute-force 5 times in 10 minutes, they get blocked for an hour. Works pretty well for stopping most automated attacks.

## Verification Script
I wrote `audit.sh` to check that everything's actually configured correctly:
- Nginx is running
- Firewall has the right rules
- SSL cert is valid
- Fail2ban is active
- No version leaks in headers
