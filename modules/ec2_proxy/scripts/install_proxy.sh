#!/bin/bash
sudo yum update -y
sudo yum install -y nginx

# Explicitly create log dir and set owner
# This ensures Nginx has permission to write its logs.
sudo mkdir -p /var/log/nginx
sudo chown nginx:nginx /var/log/nginx

# Remove the default config files
sudo rm -f /etc/nginx/nginx.conf
sudo rm -f /etc/nginx/conf.d/default.conf

# ➡️ FIX: Write configuration directly to the primary Nginx config file ⬅️
sudo bash -c 'cat > /etc/nginx/nginx.conf <<EOF
user nginx;
worker_processes auto;
error_log /var/log/nginx/error.log;
pid /run/nginx.pid;

include /usr/share/nginx/modules/*.conf;

events {
    worker_connections 1024;
}

http {
    log_format  main  '"$remote_addr - $remote_user [$time_local] "$request" "'
                      '"$status $body_bytes_sent "$http_referer" "'
                      '"$http_user_agent" "$http_x_forwarded_for"';

    access_log  /var/log/nginx/access.log  main;

    sendfile            on;
    tcp_nopush          on;
    keepalive_timeout   65;
    types_hash_max_size 4096;

    include             /etc/nginx/mime.types;
    default_type        application/octet-stream;
    
    # ➡️ CUSTOM SERVER BLOCK STARTS HERE ⬅️
    server {
        listen 80;
        location / {
            proxy_pass http://internal-secure-webapp-internal-1527171465.us-east-1.elb.amazonaws.com; 
            proxy_set_header Host \$host;
            proxy_set_header X-Real-IP \$remote_addr;
        }
    }
}
EOF'

# Ensure the correct permissions and context are applied
sudo chown nginx:nginx /etc/nginx/nginx.conf

# Use the most reliable service command: restart
sudo systemctl enable nginx
sudo systemctl restart nginx