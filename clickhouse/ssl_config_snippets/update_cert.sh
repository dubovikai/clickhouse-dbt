sudo su
cd clickhouse
source ./certbot/bin/activate
certbot renew --cert-name host.com

cp -u /etc/letsencrypt/live/host.com/*.pem ./ca/
chmod 644 ./ca/*.pem
