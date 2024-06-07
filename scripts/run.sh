#!/bin/bash

cd /app || exit 1

python3 app.py background&
python3 app.py web&
sleep 5s
/usr/local/bin/mihomo -d /etc/mihomo