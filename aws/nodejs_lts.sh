#!/bin/bash
# 
# ubuntu16-scripts by mrostanski
#
# Node.js LTS installation and permissions config for ubuntu user
#
# Usage: run as root or insert into EC2 userdata
#       (you can change ubuntu into desired user)

apt-get update
apt-get -y upgrade

# build tools
apt-get install -y build-essential cmake tcl

# synchro tools
apt-get install -y curl

# Node LTS install

curl -sL https://deb.nodesource.com/setup_6.x | sudo -E bash -
apt-get install -y nodejs

# Permissions for global, the right way
mkdir /home/ubuntu/.npm-global
chown ubuntu:ubuntu /home/ubuntu/.npm-global
echo "export PATH=~/.npm-global/bin:$PATH" >> /home/ubuntu/.profile
sudo -Hu ubuntu npm config set prefix '~/.npm-global'