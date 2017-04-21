#!/bin/bash
# 
# ubuntu16-scripts by mrostanski
#
# Redis In-Memory Data Store installation and basic config
# Configuration for systemd of Ubuntu 16.04 LTS
# WARNING - Redis is open to EVERYTHING, use system firewall rules!
#
# Redis database is installed in /var/lib/redis
#
# Usage: run as root or insert into EC2 userdata
#

apt-get update
apt-get -y upgrade

# build tools
apt-get install -y build-essential cmake tcl

# synchro tools
apt-get install -y curl

cd /tmp
curl -O http://download.redis.io/redis-stable.tar.gz
tar xzvf redis-stable.tar.gz
cd redis-stable/
make && make test && make install
mkdir /etc/redis
cp /tmp/redis-stable/redis.conf /etc/redis/

sed -i -e 's/^bind 127.0.0.1/bind 0.0.0.0/g' /etc/redis/redis.conf
sed -i -e 's/^supervised no/supervised systemd/g' /etc/redis/redis.conf
sed -i -e 's/^dir \.\//dir \/var\/lib\/redis/g' /etc/redis/redis.conf
sed -i -e 's/^protected-mode yes/protected-mode no/g' /etc/redis/redis.conf

cat << EOF > /etc/systemd/system/redis.service

[Unit]
Description=Redis In-Memory Data Store
After=network.target

[Service]
User=redis
Group=redis
ExecStart=/usr/local/bin/redis-server /etc/redis/redis.conf
ExecStop=/usr/local/bin/redis-cli shutdown
Restart=always

[Install]
WantedBy=multi-user.target

EOF

adduser --system --group --no-create-home redis
mkdir /var/lib/redis
chown redis:redis /var/lib/redis
chmod 770 /var/lib/redis
systemctl start redis
systemctl enable redis