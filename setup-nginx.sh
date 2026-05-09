#!/usr/bin/env bash
set -euo pipefail

if [[ "${EUID}" -ne 0 ]]; then
  echo "Please run as root: sudo bash setup-nginx.sh"
  exit 1
fi

apt-get update
apt-get install -y nginx

install -m 0644 nginx-blog.conf /etc/nginx/sites-available/blog
ln -sfn /etc/nginx/sites-available/blog /etc/nginx/sites-enabled/blog
rm -f /etc/nginx/sites-enabled/default

nginx -t
systemctl enable nginx
systemctl reload nginx || systemctl restart nginx

echo "Nginx is serving /home/ddxd/blog/public on port 80."
