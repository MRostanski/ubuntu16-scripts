#!/bin/bash
# 
# ubuntu16-scripts by mrostanski
#
# Full installation for MEAN stack projects development:
#
# MongoDB - high-performance, schema-free document-oriented database installation and basic config
# Redis In-Memory Data Store installation and basic config
# Node.js LTS installation and permissions config for ubuntu user
# Express framework
#
# Configuration for systemd of Ubuntu 16.04 LTS
#
# Mongo 3.2 is used as of today (15.04.2017) Mongo 3.4 has some unresolved issues with Ubuntu 16.04
#
# Usage: run as root or insert into EC2 userdata
#

# MongoDB install and config
apt-get update
apt-get -y upgrade

# build tools
apt-get install -y build-essential cmake tcl
apt-get install -y python2.7 python2.7-dev

# synchro tools
apt-get install -y curl git

# local load balancer and ssl termination (haproxy REMOVED IN FAVOR OF AWS ELB)
apt-get install -y openssl libssl-dev

# Syslog configuration - enable udp, add a sender, add a source, restart syslog

sed -i '/^#.*module(load="imudp")/s/^#//' /etc/rsyslog.conf
sed -i '/^#.*input(type="imudp" port="514")/s/^#//' /etc/rsyslog.conf
sed -i '/type="imudp" port="514"/a $AllowedSender UDP, 127.0.0.1' /etc/rsyslog.conf
sed -i -e 's/\*\.\*;auth,authpriv.none/\*\.\*;auth,authpriv.none;local2.none/g' /etc/rsyslog.d/50-default.conf
systemctl restart rsyslog
echo "Rsyslog reconfigured"

# Node LTS install

curl -sL https://deb.nodesource.com/setup_6.x | sudo -E bash -
apt-get install -y nodejs

mkdir /home/ubuntu/.npm-global
chown ubuntu:ubuntu /home/ubuntu/.npm-global
echo "export PATH=~/.npm-global/bin:$PATH" >> /home/ubuntu/.profile
sudo -Hu ubuntu npm config set prefix '~/.npm-global'
sudo -Hu ubuntu npm install -g coffee-script eslint typescript node-gyp express express-generator

# Redis install and config

cd /tmp
curl -O http://download.redis.io/redis-stable.tar.gz
tar xzvf redis-stable.tar.gz
cd redis-stable/
make && make test && make install
mkdir /etc/redis
cp /tmp/redis-stable/redis.conf /etc/redis/

sed -i -e 's/^supervised no/supervised systemd/g' /etc/redis/redis.conf
sed -i -e 's/^dir \.\//dir \/var\/lib\/redis/g' /etc/redis/redis.conf

# if you want Mongo opened for other hosts, uncomment:
#sed -i -e 's/^bind 127.0.0.1/bind 0.0.0.0/g' /etc/redis/redis.conf
#sed -i -e 's/^protected-mode yes/protected-mode no/g' /etc/redis/redis.conf

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

# MongoDB install and config

apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv EA312927
echo "deb http://repo.mongodb.org/apt/ubuntu trusty/mongodb-org/3.2 multiverse" >> /etc/apt/sources.list.d/mongodb-org-3.2.list

apt-get update
apt-get install -y mongodb-org
# if you want Mongo opened for other hosts, uncomment:
# sed -i -e 's/bindIp: 127.0.0.1/bindIp: 0.0.0.0/g' /etc/mongod.conf

cat << EOF > /etc/systemd/system/mongodb.service

[Unit]
Description=High-performance, schema-free document-oriented database
After=network.target

[Service]
User=mongodb
ExecStart=/usr/bin/mongod --quiet --config /etc/mongod.conf

[Install]
WantedBy=multi-user.target

EOF

systemctl start mongodb
systemctl enable mongodb


