#!/bin/bash
# 
# ubuntu16-scripts by mrostanski
#
# MongoDB - high-performance, schema-free document-oriented database installation and basic config
# Configuration for systemd of Ubuntu 16.04 LTS
# WARNING - Mongo is open to everything, use system firewall rules!
#
# Mongo 3.2 is used as of today (15.04.2017) Mongo 3.4 has some unresolved issues with Ubuntu 16.04
#
# Usage: run as root or insert into EC2 userdata
#

# MongoDB install and config

apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv EA312927
echo "deb http://repo.mongodb.org/apt/ubuntu trusty/mongodb-org/3.2 multiverse" >> /etc/apt/sources.list.d/mongodb-org-3.2.list

apt-get update
apt-get install -y mongodb-org
sed -i -e 's/bindIp: 127.0.0.1/bindIp: 0.0.0.0/g' /etc/mongod.conf

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