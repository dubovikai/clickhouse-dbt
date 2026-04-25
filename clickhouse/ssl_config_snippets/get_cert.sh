#!/bin/sh

cd clickhouse
python -m venv certbot
source ./certbot/bin/activate
pip install certbot certbot-dns-route53
certbot certonly
...