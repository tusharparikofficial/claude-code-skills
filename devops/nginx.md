# Generate Nginx Configuration

Generate production-ready Nginx configuration for reverse proxy, static file serving, SPA, API gateway, or SSL termination.

## Arguments

$ARGUMENTS - `<config-type>` where type is one of: reverse-proxy, static, spa, api, ssl

## Instructions

### 1. Parse Arguments

Extract the config type from `$ARGUMENTS`. Supported types:
- `reverse-proxy` - Reverse proxy to upstream application server
- `static` - Static file serving with caching
- `spa` - Single Page Application with client-side routing
- `api` - API gateway with rate limiting, CORS, load balancing
- `ssl` - SSL/TLS termination with Let's Encrypt

If not provided, ask the user which type they need.

### 2. Gather Configuration Details

Ask the user for (or infer from the project):
- **Domain name(s)**: e.g., `example.com`, `api.example.com`
- **Upstream port**: Application port to proxy to (for reverse-proxy, api, ssl)
- **Static files path**: Document root (for static, spa)
- **SSL**: Whether to include SSL (offer Let's Encrypt setup)
- **WebSocket**: Whether WebSocket support is needed

Also detect from project files:
- Check `docker-compose.yml` for service ports
- Check `.env` for domain/port configuration
- Check for Next.js, React, Vue, Angular to determine SPA needs

### 3. Common Configuration Blocks

All generated configs include these reusable blocks:

#### Performance Optimizations
```nginx
# --- Performance ---
worker_processes auto;
worker_rlimit_nofile 65535;

events {
    worker_connections 4096;
    multi_accept on;
    use epoll;
}

http {
    # Basic settings
    sendfile on;
    tcp_nopush on;
    tcp_nodelay on;
    keepalive_timeout 65;
    keepalive_requests 100;
    types_hash_max_size 2048;
    server_tokens off;              # Hide nginx version
    client_max_body_size 16M;

    # MIME types
    include /etc/nginx/mime.types;
    default_type application/octet-stream;

    # Gzip compression
    gzip on;
    gzip_vary on;
    gzip_proxied any;
    gzip_comp_level 6;
    gzip_min_length 1000;
    gzip_types
        text/plain
        text/css
        text/xml
        text/javascript
        application/json
        application/javascript
        application/xml
        application/xml+rss
        application/atom+xml
        image/svg+xml
        font/woff2;

    # Brotli compression (if module available)
    # brotli on;
    # brotli_comp_level 6;
    # brotli_types text/plain text/css application/json application/javascript text/xml application/xml image/svg+xml;

    # Buffer sizes
    client_body_buffer_size 16k;
    client_header_buffer_size 1k;
    large_client_header_buffers 4 8k;
```

#### Security Headers
```nginx
    # --- Security Headers ---
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "0" always;
    add_header Referrer-Policy "strict-origin-when-cross-origin" always;
    add_header Permissions-Policy "camera=(), microphone=(), geolocation=(), payment=()" always;
    # Content-Security-Policy should be customized per application:
    # add_header Content-Security-Policy "default-src 'self'; script-src 'self'; style-src 'self' 'unsafe-inline';" always;
```

#### Rate Limiting
```nginx
    # --- Rate Limiting ---
    limit_req_zone $binary_remote_addr zone=general:10m rate=10r/s;
    limit_req_zone $binary_remote_addr zone=api:10m rate=30r/s;
    limit_req_zone $binary_remote_addr zone=login:10m rate=5r/m;
    limit_req_status 429;
```

#### Logging
```nginx
    # --- Logging ---
    log_format main '$remote_addr - $remote_user [$time_local] '
                    '"$request" $status $body_bytes_sent '
                    '"$http_referer" "$http_user_agent" '
                    '$request_time $upstream_response_time';

    log_format json escape=json '{'
        '"time":"$time_iso8601",'
        '"remote_addr":"$remote_addr",'
        '"request":"$request",'
        '"status":$status,'
        '"body_bytes_sent":$body_bytes_sent,'
        '"request_time":$request_time,'
        '"upstream_response_time":"$upstream_response_time",'
        '"http_user_agent":"$http_user_agent"'
    '}';

    access_log /var/log/nginx/access.log main;
    error_log /var/log/nginx/error.log warn;
```

### 4. Reverse Proxy Configuration

```nginx
    upstream app_backend {
        server 127.0.0.1:3000;
        # For load balancing multiple instances:
        # server 127.0.0.1:3001;
        # server 127.0.0.1:3002;
        keepalive 32;
    }

    server {
        listen 80;
        server_name <domain>;

        # Redirect to HTTPS (uncomment when SSL is configured)
        # return 301 https://$server_name$request_uri;

        location / {
            proxy_pass http://app_backend;
            proxy_http_version 1.1;

            # Headers
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Request-ID $request_id;

            # WebSocket support
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection "upgrade";

            # Timeouts
            proxy_connect_timeout 60s;
            proxy_send_timeout 60s;
            proxy_read_timeout 60s;

            # Buffering
            proxy_buffering on;
            proxy_buffer_size 4k;
            proxy_buffers 8 4k;
            proxy_busy_buffers_size 8k;

            # Rate limiting
            limit_req zone=general burst=20 nodelay;
        }

        # Health check endpoint (no rate limiting, no logging)
        location /api/health {
            proxy_pass http://app_backend;
            proxy_http_version 1.1;
            proxy_set_header Host $host;
            access_log off;
        }

        # Deny access to hidden files
        location ~ /\. {
            deny all;
            access_log off;
            log_not_found off;
        }
    }
```

### 5. Static File Configuration

```nginx
    server {
        listen 80;
        server_name <domain>;

        root /var/www/<domain>/public;
        index index.html;

        # Security
        autoindex off;
        etag on;

        # HTML files - no cache (always fetch latest)
        location ~* \.html$ {
            add_header Cache-Control "no-cache, no-store, must-revalidate";
            add_header Pragma "no-cache";
            try_files $uri $uri/ =404;
        }

        # Immutable assets (hashed filenames from build tools)
        location ~* \.(js|css|woff2|woff|ttf|eot)$ {
            add_header Cache-Control "public, max-age=31536000, immutable";
            access_log off;
        }

        # Images
        location ~* \.(jpg|jpeg|png|gif|ico|svg|webp|avif)$ {
            add_header Cache-Control "public, max-age=2592000";  # 30 days
            access_log off;
        }

        # Default
        location / {
            try_files $uri $uri/ =404;
            limit_req zone=general burst=20 nodelay;
        }

        # Deny hidden files
        location ~ /\. {
            deny all;
            access_log off;
            log_not_found off;
        }

        # Custom error pages
        error_page 404 /404.html;
        error_page 500 502 503 504 /50x.html;
        location = /50x.html {
            root /usr/share/nginx/html;
        }
    }
```

### 6. SPA Configuration

```nginx
    upstream api_backend {
        server 127.0.0.1:4000;
        keepalive 16;
    }

    server {
        listen 80;
        server_name <domain>;

        root /var/www/<domain>/dist;
        index index.html;

        # SPA routing - serve index.html for all routes
        location / {
            try_files $uri $uri/ /index.html;
            add_header Cache-Control "no-cache";
            limit_req zone=general burst=20 nodelay;
        }

        # Static assets with long cache (hashed filenames)
        location /assets/ {
            add_header Cache-Control "public, max-age=31536000, immutable";
            access_log off;
        }

        # API proxy (if backend on same domain)
        location /api/ {
            proxy_pass http://api_backend;
            proxy_http_version 1.1;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;

            # WebSocket support for API
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection "upgrade";

            # API rate limiting
            limit_req zone=api burst=50 nodelay;
        }

        # Fonts with CORS
        location ~* \.(woff2?|ttf|eot|otf)$ {
            add_header Cache-Control "public, max-age=31536000, immutable";
            add_header Access-Control-Allow-Origin "*";
            access_log off;
        }

        # Images
        location ~* \.(jpg|jpeg|png|gif|ico|svg|webp|avif)$ {
            add_header Cache-Control "public, max-age=2592000";
            access_log off;
        }

        # Deny hidden files
        location ~ /\. {
            deny all;
        }
    }
```

### 7. API Gateway Configuration

```nginx
    upstream api_servers {
        least_conn;                      # Load balancing strategy
        server 127.0.0.1:4000 weight=3;
        server 127.0.0.1:4001 weight=2;
        server 127.0.0.1:4002 weight=1;
        keepalive 64;
    }

    # Map for CORS origin validation
    map $http_origin $cors_origin {
        default "";
        "~^https://example\.com$" $http_origin;
        "~^https://.*\.example\.com$" $http_origin;
        "http://localhost:3000" $http_origin;  # Dev only
    }

    server {
        listen 80;
        server_name api.<domain>;

        # Request body size limit
        client_max_body_size 10M;

        # CORS preflight
        location = /cors-preflight {
            internal;
            add_header Access-Control-Allow-Origin $cors_origin always;
            add_header Access-Control-Allow-Methods "GET, POST, PUT, PATCH, DELETE, OPTIONS" always;
            add_header Access-Control-Allow-Headers "Authorization, Content-Type, X-Request-ID" always;
            add_header Access-Control-Max-Age 86400 always;
            add_header Content-Length 0;
            return 204;
        }

        location / {
            # Handle CORS preflight
            if ($request_method = 'OPTIONS') {
                add_header Access-Control-Allow-Origin $cors_origin always;
                add_header Access-Control-Allow-Methods "GET, POST, PUT, PATCH, DELETE, OPTIONS" always;
                add_header Access-Control-Allow-Headers "Authorization, Content-Type, X-Request-ID" always;
                add_header Access-Control-Max-Age 86400;
                add_header Content-Length 0;
                return 204;
            }

            # CORS response headers
            add_header Access-Control-Allow-Origin $cors_origin always;

            proxy_pass http://api_servers;
            proxy_http_version 1.1;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Request-ID $request_id;
            proxy_set_header Connection "";

            # Timeouts for potentially long API calls
            proxy_connect_timeout 30s;
            proxy_send_timeout 120s;
            proxy_read_timeout 120s;

            # API rate limiting
            limit_req zone=api burst=50 nodelay;
        }

        # Stricter rate limiting for auth endpoints
        location /api/auth/ {
            proxy_pass http://api_servers;
            proxy_http_version 1.1;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            limit_req zone=login burst=3 nodelay;
        }

        # Health check (no rate limiting)
        location /health {
            proxy_pass http://api_servers;
            access_log off;
        }

        # JSON error pages
        error_page 429 = @rate_limited;
        location @rate_limited {
            default_type application/json;
            return 429 '{"error":"Too Many Requests","message":"Rate limit exceeded. Please retry later."}';
        }

        error_page 502 503 504 = @upstream_error;
        location @upstream_error {
            default_type application/json;
            return 503 '{"error":"Service Unavailable","message":"The service is temporarily unavailable."}';
        }

        # Deny hidden files
        location ~ /\. {
            deny all;
        }
    }
```

### 8. SSL Configuration

```nginx
    # HTTP -> HTTPS redirect
    server {
        listen 80;
        server_name <domain> www.<domain>;

        # Let's Encrypt challenge
        location /.well-known/acme-challenge/ {
            root /var/www/certbot;
        }

        location / {
            return 301 https://$server_name$request_uri;
        }
    }

    # HTTPS server
    server {
        listen 443 ssl http2;
        server_name <domain>;

        # --- SSL Certificate ---
        ssl_certificate /etc/letsencrypt/live/<domain>/fullchain.pem;
        ssl_certificate_key /etc/letsencrypt/live/<domain>/privkey.pem;

        # --- TLS Configuration (Mozilla Modern) ---
        ssl_protocols TLSv1.2 TLSv1.3;
        ssl_ciphers ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384;
        ssl_prefer_server_ciphers off;

        # --- HSTS (2 years, include subdomains, allow preloading) ---
        add_header Strict-Transport-Security "max-age=63072000; includeSubDomains; preload" always;

        # --- OCSP Stapling ---
        ssl_stapling on;
        ssl_stapling_verify on;
        ssl_trusted_certificate /etc/letsencrypt/live/<domain>/chain.pem;
        resolver 8.8.8.8 8.8.4.4 valid=300s;
        resolver_timeout 5s;

        # --- SSL Session ---
        ssl_session_cache shared:SSL:10m;
        ssl_session_timeout 1d;
        ssl_session_tickets off;

        # --- DH Parameters (generate with: openssl dhparam -out /etc/nginx/dhparam.pem 4096) ---
        # ssl_dhparam /etc/nginx/dhparam.pem;

        # Application configuration goes here (reverse-proxy, static, spa, or api)
        location / {
            proxy_pass http://app_backend;
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

### 9. Generate Docker Compose Service

Create or suggest adding an Nginx service to `docker-compose.yml`:

```yaml
  nginx:
    image: nginx:1.25-alpine
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf:ro
      - ./certbot/conf:/etc/letsencrypt:ro
      - ./certbot/www:/var/www/certbot:ro
    depends_on:
      - app
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "wget", "--no-verbose", "--tries=1", "--spider", "http://localhost/"]
      interval: 30s
      timeout: 5s
      retries: 3

  # For SSL certificate management
  certbot:
    image: certbot/certbot:latest
    volumes:
      - ./certbot/conf:/etc/letsencrypt
      - ./certbot/www:/var/www/certbot
    entrypoint: "/bin/sh -c 'trap exit TERM; while :; do certbot renew; sleep 12h & wait $${!}; done'"
```

### 10. SSL Setup Commands

If SSL configuration is included, provide the commands to set up Let's Encrypt:

```bash
# First-time certificate setup
sudo certbot certonly --webroot \
  -w /var/www/certbot \
  -d <domain> \
  -d www.<domain> \
  --email admin@<domain> \
  --agree-tos \
  --no-eff-email

# Test auto-renewal
sudo certbot renew --dry-run

# Generate DH parameters (one-time, takes a few minutes)
sudo openssl dhparam -out /etc/nginx/dhparam.pem 4096
```

### 11. Write Files and Report

Write `nginx.conf` to the project directory.

Print a summary with:
- Configuration type generated
- Key features enabled (compression, security headers, rate limiting, caching, SSL)
- How to test syntax: `nginx -t` or `docker compose exec nginx nginx -t`
- How to reload: `nginx -s reload` or `docker compose exec nginx nginx -s reload`
- SSL setup steps (if applicable)
- Performance recommendations
- Security checklist verified
- Any manual steps needed (DNS configuration, certificate setup)
