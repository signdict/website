# This is the nginx config that you need
# to install the letsencrypt certificate.

server {
  listen         80;
  listen    [::]:80;
  server_name    signdict.org new.signdict.org;

  server_tokens off;

  location /.well-known/ {
    root /var/www/html/;
  }

  location / {
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header Host $http_host;
    proxy_redirect off;
    proxy_pass http://localhost:4000;
    proxy_set_header Upgrade $http_upgrade;
    proxy_set_header Connection "upgrade";
  }
}
