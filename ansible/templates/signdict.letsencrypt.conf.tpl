upstream backend {
    server 127.0.0.1:4000 fail_timeout=2s; #The backend
    server 127.0.0.1:8502 backup; #Lua holding server in the event backend is restarting
    server 127.0.0.1:4000 backup; #Another backend
}

server {
    listen 8502;

    server_tokens off;

    location / {
        #25 seconds sleep
        content_by_lua_block {
             ngx.sleep(25); 
             ngx.exit(ngx.HTTP_BAD_GATEWAY);
        }
    }
}

server {
  listen 443 ssl http2 default_server;
  listen [::]:443 ssl http2 default_server;
  server_name signdict.org *.signdict.org;

  recursive_error_pages on;

  server_tokens off;

  client_max_body_size 100m;

  ssl_certificate_key /etc/letsencrypt/live/new.signdict.org/privkey.pem;
  ssl_certificate /etc/letsencrypt/live/new.signdict.org/fullchain.pem;
  ssl_dhparam /etc/nginx/ssl/dhparam.pem;

  location /.well-known/ {
    root /var/www/html/;
  }

  location / {
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header Host $http_host;
    proxy_redirect off;
    proxy_pass http://backend;
    proxy_set_header Upgrade $http_upgrade;
    proxy_set_header Connection "upgrade";
    proxy_read_timeout 30;
    proxy_next_upstream error timeout http_502 http_504;
  }
}

server {
  listen         80;
  listen    [::]:80;
  server_name    signdict.org *.signdict.org;
  return         301 https://$host$request_uri;
}
