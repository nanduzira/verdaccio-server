upstream verdaccio {
    server localhost:4873;
    keepalive 8;
}

server {
    listen 80 default_server;
    access_log /var/log/nginx/verdaccio.log;
    charset utf-8;

    location ~ ^/verdaccio/(.*)$ {
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_set_header Host $host:$server_port;
        proxy_set_header X-NginX-Proxy true;
        proxy_pass http://verdaccio/$1;
        proxy_redirect off;
    }

}
