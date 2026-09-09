#!/bin/bash

echo "===== Web Server Hardening Audit: $(date '+%Y-%m-%d %H:%M:%S') ====="
echo ""


if systemctl is-active --quiet nginx; then
    echo "[PASS] Nginx is running"
else
    echo "[FAIL] Nginx is NOT running"
fi

if systemctl is-active --quiet firewalld; then
    echo "[PASS] firewalld is running"
else
    echo "[FAIL] firewalld is NOT running"
fi

allowed=$(sudo firewall-cmd --list-services)
echo "[INFO] Allowed firewall services: $allowed"
if echo "$allowed" | grep -qE "cockpit|nfs"; then
    echo "[FAIL] Unnecessary services still open (cockpit/nfs)"
else
    echo "[PASS] No unnecessary services open"
fi


if openssl x509 -checkend 0 -noout -in /etc/nginx/ssl/nginx-selfsigned.crt >/dev/null 2>&1; then
    echo "[PASS] SSL certificate is valid"
else
    echo "[FAIL] SSL certificate expired or missing"
fi


if systemctl is-active --quiet fail2ban; then
    echo "[PASS] fail2ban is running"
else
    echo "[FAIL] fail2ban is NOT running"
fi


if curl -sIk https://localhost | grep -i "^Server:" | grep -qv "nginx/"; then
    echo "[PASS] Nginx version is hidden (server_tokens off)"
else
    echo "[FAIL] Nginx is leaking version info"
fi

echo ""
echo "===== Audit Complete ====="


