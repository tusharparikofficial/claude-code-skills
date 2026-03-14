# Set Up SSL/TLS Certificates

Set up SSL/TLS certificates using Let's Encrypt, self-signed certificates for development, or Cloudflare origin certificates.

## Arguments

$ARGUMENTS - `<domain>` or `<method>` where method is one of: letsencrypt, self-signed, cloudflare

## Instructions

### 1. Parse Arguments

Determine what was provided in `$ARGUMENTS`:
- If it looks like a domain (contains a dot, e.g., `example.com`): use Let's Encrypt by default and set the domain
- If it is a method keyword (`letsencrypt`, `self-signed`, `cloudflare`): use that method and ask for the domain
- If nothing provided: ask the user for both the method and domain

### 2. Detect Environment

Check the environment to understand the setup:
- Is this running on a VPS or local machine?
- Is Nginx installed? (`which nginx`)
- Is Docker being used? (check for `docker-compose.yml`)
- Is there an existing Nginx config? (check `/etc/nginx/` or project `nginx.conf`)
- What web server is being used?

### 3. Let's Encrypt (Production SSL)

#### 3a. Prerequisites Check

```bash
# Check if certbot is installed
if ! command -v certbot &> /dev/null; then
    echo "Installing certbot..."
    # Ubuntu/Debian
    sudo apt-get update
    sudo apt-get install -y certbot python3-certbot-nginx
fi

# Check if Nginx is running
sudo systemctl status nginx

# Check if DNS is pointing to this server
CURRENT_IP=$(curl -s ifconfig.me)
DNS_IP=$(dig +short <domain>)
if [ "$CURRENT_IP" != "$DNS_IP" ]; then
    echo "WARNING: DNS for <domain> points to $DNS_IP but this server is $CURRENT_IP"
    echo "Update DNS before proceeding."
fi
```

#### 3b. Obtain Certificate

**Method 1: Nginx plugin (recommended)**
```bash
sudo certbot --nginx \
    -d <domain> \
    -d www.<domain> \
    --non-interactive \
    --agree-tos \
    --email admin@<domain> \
    --redirect
```

**Method 2: Webroot (if Nginx is already configured)**
```bash
sudo mkdir -p /var/www/certbot

sudo certbot certonly --webroot \
    -w /var/www/certbot \
    -d <domain> \
    -d www.<domain> \
    --non-interactive \
    --agree-tos \
    --email admin@<domain>
```

**Method 3: Standalone (no web server running)**
```bash
sudo certbot certonly --standalone \
    -d <domain> \
    -d www.<domain> \
    --non-interactive \
    --agree-tos \
    --email admin@<domain>
```

**Method 4: Docker-based (using docker-compose)**

Add to `docker-compose.yml`:
```yaml
services:
  nginx:
    image: nginx:1.25-alpine
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf:ro
      - certbot_conf:/etc/letsencrypt:ro
      - certbot_www:/var/www/certbot:ro
    depends_on:
      - app
    restart: unless-stopped

  certbot:
    image: certbot/certbot:latest
    volumes:
      - certbot_conf:/etc/letsencrypt
      - certbot_www:/var/www/certbot
    entrypoint: "/bin/sh -c 'trap exit TERM; while :; do certbot renew; sleep 12h & wait $${!}; done'"

volumes:
  certbot_conf:
  certbot_www:
```

Initial certificate generation:
```bash
docker compose run --rm certbot certonly --webroot -w /var/www/certbot -d <domain> --agree-tos --email admin@<domain>
```

#### 3c. Configure Auto-Renewal

**Systemd timer (preferred):**
```bash
# Check if certbot timer is already installed
sudo systemctl list-timers | grep certbot

# If not present, create it:
sudo tee /etc/systemd/system/certbot-renewal.timer << 'EOF'
[Unit]
Description=Certbot renewal timer

[Timer]
OnCalendar=*-*-* 02:00:00
RandomizedDelaySec=3600
Persistent=true

[Install]
WantedBy=timers.target
EOF

sudo tee /etc/systemd/system/certbot-renewal.service << 'EOF'
[Unit]
Description=Certbot renewal service
After=network-online.target

[Service]
Type=oneshot
ExecStart=/usr/bin/certbot renew --quiet --deploy-hook "systemctl reload nginx"
EOF

sudo systemctl daemon-reload
sudo systemctl enable certbot-renewal.timer
sudo systemctl start certbot-renewal.timer
```

**Cron job (alternative):**
```bash
echo "0 2 * * * certbot renew --quiet --deploy-hook 'systemctl reload nginx'" | sudo tee -a /etc/crontab
```

**Test renewal:**
```bash
sudo certbot renew --dry-run
```

#### 3d. Configure Nginx for SSL

Generate or update Nginx configuration:

```nginx
# HTTP -> HTTPS redirect
server {
    listen 80;
    server_name <domain> www.<domain>;

    location /.well-known/acme-challenge/ {
        root /var/www/certbot;
    }

    location / {
        return 301 https://$host$request_uri;
    }
}

# HTTPS server
server {
    listen 443 ssl http2;
    server_name <domain>;

    # SSL certificates (Let's Encrypt)
    ssl_certificate /etc/letsencrypt/live/<domain>/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/<domain>/privkey.pem;
    ssl_trusted_certificate /etc/letsencrypt/live/<domain>/chain.pem;

    # TLS configuration (Mozilla Modern)
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384;
    ssl_prefer_server_ciphers off;

    # HSTS (2 years)
    add_header Strict-Transport-Security "max-age=63072000; includeSubDomains; preload" always;

    # OCSP Stapling
    ssl_stapling on;
    ssl_stapling_verify on;
    resolver 8.8.8.8 8.8.4.4 valid=300s;
    resolver_timeout 5s;

    # SSL session
    ssl_session_cache shared:SSL:10m;
    ssl_session_timeout 1d;
    ssl_session_tickets off;

    # DH parameters (optional, generate: openssl dhparam -out /etc/nginx/dhparam.pem 4096)
    # ssl_dhparam /etc/nginx/dhparam.pem;

    # Application reverse proxy
    location / {
        proxy_pass http://127.0.0.1:3000;
        proxy_http_version 1.1;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
    }
}
```

Test and reload:
```bash
sudo nginx -t && sudo systemctl reload nginx
```

### 4. Self-Signed Certificates (Development)

#### 4a. Using mkcert (recommended for local development)

```bash
# Install mkcert
# macOS
brew install mkcert nss

# Linux
sudo apt-get install -y libnss3-tools
curl -JLO "https://dl.filippo.io/mkcert/latest?for=linux/amd64"
chmod +x mkcert-v*-linux-amd64
sudo mv mkcert-v*-linux-amd64 /usr/local/bin/mkcert

# Install local CA
mkcert -install

# Generate certificates
mkdir -p certs
mkcert -cert-file certs/local-cert.pem -key-file certs/local-key.pem \
    localhost 127.0.0.1 ::1 <domain>.local "*.local"

echo "Certificates generated:"
echo "  Certificate: certs/local-cert.pem"
echo "  Key:         certs/local-key.pem"
```

#### 4b. Using OpenSSL (no CA trust)

```bash
mkdir -p certs

openssl req -x509 -nodes -days 365 \
    -newkey rsa:2048 \
    -keyout certs/self-signed-key.pem \
    -out certs/self-signed-cert.pem \
    -subj "/C=US/ST=State/L=City/O=Dev/CN=localhost" \
    -addext "subjectAltName=DNS:localhost,DNS:*.localhost,IP:127.0.0.1"

echo "Self-signed certificate generated (browsers will show a warning)."
```

#### 4c. Configure in Project

**Node.js / Express:**
```typescript
import https from "https";
import fs from "fs";
import app from "./app";

const options = {
  key: fs.readFileSync("certs/local-key.pem"),
  cert: fs.readFileSync("certs/local-cert.pem"),
};

https.createServer(options, app).listen(443, () => {
  console.log("HTTPS server running on https://localhost");
});
```

**Docker Compose (dev):**
```yaml
services:
  app:
    volumes:
      - ./certs:/app/certs:ro
    environment:
      - SSL_CERT_PATH=/app/certs/local-cert.pem
      - SSL_KEY_PATH=/app/certs/local-key.pem
```

**Nginx (dev):**
```nginx
server {
    listen 443 ssl;
    server_name localhost;
    ssl_certificate /etc/nginx/certs/local-cert.pem;
    ssl_certificate_key /etc/nginx/certs/local-key.pem;
    location / {
        proxy_pass http://app:3000;
    }
}
```

Add certs to `.gitignore`:
```
certs/
*.pem
```

### 5. Cloudflare SSL

#### 5a. Cloudflare Origin Certificate

Instructions for generating Cloudflare origin certificates:

1. Log into Cloudflare Dashboard
2. Select the domain
3. Go to SSL/TLS > Origin Server
4. Click "Create Certificate"
5. Choose:
   - Private key type: RSA (2048)
   - Hostnames: `<domain>`, `*.<domain>`
   - Certificate validity: 15 years
6. Save the certificate and private key

```bash
# Save certificate files on the server
sudo mkdir -p /etc/cloudflare

# Paste certificate into file
sudo tee /etc/cloudflare/<domain>.pem << 'EOF'
# Paste certificate here
EOF

# Paste private key into file
sudo tee /etc/cloudflare/<domain>.key << 'EOF'
# Paste private key here
EOF

sudo chmod 600 /etc/cloudflare/<domain>.key
```

#### 5b. Configure Cloudflare SSL Mode

Set the SSL/TLS encryption mode in Cloudflare Dashboard:
- **Full (Strict)** - recommended when using origin certificates
- Dashboard path: SSL/TLS > Overview > Set to "Full (strict)"

#### 5c. Configure Nginx for Cloudflare

```nginx
server {
    listen 443 ssl http2;
    server_name <domain>;

    # Cloudflare Origin Certificate
    ssl_certificate /etc/cloudflare/<domain>.pem;
    ssl_certificate_key /etc/cloudflare/<domain>.key;

    # Cloudflare Authenticated Origin Pulls (optional, extra security)
    # ssl_client_certificate /etc/cloudflare/authenticated_origin_pull_ca.pem;
    # ssl_verify_client on;

    # TLS configuration
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384;
    ssl_prefer_server_ciphers off;

    # Restore real visitor IP (Cloudflare proxy IPs)
    set_real_ip_from 173.245.48.0/20;
    set_real_ip_from 103.21.244.0/22;
    set_real_ip_from 103.22.200.0/22;
    set_real_ip_from 103.31.4.0/22;
    set_real_ip_from 141.101.64.0/18;
    set_real_ip_from 108.162.192.0/18;
    set_real_ip_from 190.93.240.0/20;
    set_real_ip_from 188.114.96.0/20;
    set_real_ip_from 197.234.240.0/22;
    set_real_ip_from 198.41.128.0/17;
    set_real_ip_from 162.158.0.0/15;
    set_real_ip_from 104.16.0.0/13;
    set_real_ip_from 104.24.0.0/14;
    set_real_ip_from 172.64.0.0/13;
    set_real_ip_from 131.0.72.0/22;
    # IPv6
    set_real_ip_from 2400:cb00::/32;
    set_real_ip_from 2606:4700::/32;
    set_real_ip_from 2803:f800::/32;
    set_real_ip_from 2405:b500::/32;
    set_real_ip_from 2405:8100::/32;
    set_real_ip_from 2a06:98c0::/29;
    set_real_ip_from 2c0f:f248::/32;
    real_ip_header CF-Connecting-IP;

    # Security headers
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;

    location / {
        proxy_pass http://127.0.0.1:3000;
        proxy_http_version 1.1;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
    }
}
```

#### 5d. Recommended Cloudflare Settings

Provide a checklist:
- SSL/TLS: Full (Strict)
- Edge Certificates: Always Use HTTPS = ON
- Edge Certificates: Minimum TLS Version = 1.2
- Edge Certificates: Automatic HTTPS Rewrites = ON
- Edge Certificates: HSTS = Enable with includeSubDomains and preload
- Speed > Optimization: Auto Minify = CSS, JS, HTML
- Speed > Optimization: Brotli = ON
- Security: WAF = Review and enable relevant rules
- Caching: Browser Cache TTL = Respect Existing Headers

### 6. Certificate Monitoring

Set up certificate expiry monitoring regardless of method:

```bash
#!/usr/bin/env bash
# scripts/check-ssl-expiry.sh
set -euo pipefail

DOMAIN="${1:-<domain>}"
WARNING_DAYS=30
CRITICAL_DAYS=14

EXPIRY=$(echo | openssl s_client -servername "$DOMAIN" -connect "$DOMAIN:443" 2>/dev/null | openssl x509 -noout -enddate 2>/dev/null | cut -d= -f2)
EXPIRY_EPOCH=$(date -d "$EXPIRY" +%s 2>/dev/null || date -j -f "%b %d %H:%M:%S %Y %Z" "$EXPIRY" +%s 2>/dev/null)
NOW_EPOCH=$(date +%s)
DAYS_LEFT=$(( (EXPIRY_EPOCH - NOW_EPOCH) / 86400 ))

echo "Certificate for $DOMAIN expires in $DAYS_LEFT days ($EXPIRY)"

if [ "$DAYS_LEFT" -le "$CRITICAL_DAYS" ]; then
    echo "CRITICAL: Certificate expires in $DAYS_LEFT days!"
    exit 2
elif [ "$DAYS_LEFT" -le "$WARNING_DAYS" ]; then
    echo "WARNING: Certificate expires in $DAYS_LEFT days"
    exit 1
else
    echo "OK: Certificate is valid for $DAYS_LEFT more days"
    exit 0
fi
```

Add to crontab:
```bash
# Check SSL expiry daily at 8am
0 8 * * * /opt/<project>/scripts/check-ssl-expiry.sh <domain>
```

### 7. Verification

After setup, verify the SSL configuration:

```bash
# Test SSL certificate
echo | openssl s_client -servername <domain> -connect <domain>:443 2>/dev/null | openssl x509 -noout -subject -issuer -dates

# Test TLS versions
openssl s_client -connect <domain>:443 -tls1_2 < /dev/null 2>/dev/null | head -5
openssl s_client -connect <domain>:443 -tls1_3 < /dev/null 2>/dev/null | head -5

# Test with curl
curl -vI https://<domain> 2>&1 | grep -E "SSL|TLS|certificate"

# Check Nginx config
sudo nginx -t
```

Suggest testing with online tools:
- https://www.ssllabs.com/ssltest/ (SSL Labs - comprehensive test)
- https://observatory.mozilla.org/ (Mozilla Observatory - security headers)
- https://securityheaders.com/ (Security headers check)

### 8. Final Report

Print a summary with:
- Method used (Let's Encrypt / Self-signed / Cloudflare)
- Domain configured
- Certificate paths
- Expiry date
- Auto-renewal status (for Let's Encrypt)
- TLS version support (1.2 and 1.3)
- HSTS status
- Files created/modified
- Verification results
- Next steps (DNS configuration, HSTS preloading, etc.)
