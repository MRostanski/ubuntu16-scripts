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

apt-get update # update package list
apt-get -y upgrade # install updates (used "-y" instead "yes")

# build tools
apt-get install -y build-essential cmake tcl # installation of packages for Debian build, "cmake" system and "Tool Command Language" (for testing binary system)

# synchro tools
apt-get install -y curl # installation of packages for "curl" and accept installation 
# download and install redis 
cd /tmp # go to the temporary folder 
curl -O http://download.redis.io/redis-stable.tar.gz # transfer a URL, write output to a local file named like the remote file we get
tar xzvf redis-stable.tar.gz # extract the contents of a compressed tar archive
cd redis-stable/ # change to the redis directory
make && make test && make install # compile redis (&& lets you do something based on whether the previous command completed successfully),
# ^run test of the redis directory and install it onto the system
mkdir /etc/redis # starting of redise's config with creating directory 
cp /tmp/redis-stable/redis.conf /etc/redis/ #copy redis config in created redis directory 
# start testing of Redis
# this sed commands finds the pattern and replaces with another pattern
# "-e" add the commands in script to the set of commands to be run while processing the input.
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

EOF # end of life; making the program aware that no more input will be sent

adduser --system --group --no-create-home redis # add a system user with name redis; to place the new system user in a new group; do not create the home directory, even if it doesn't exist.
mkdir /var/lib/redis # create redis directory
chown redis:redis /var/lib/redis # set ownership of /var/lib/redis to redis user and group
chmod 770 /var/lib/redis # adjust permissions of /var/lib/redis (all the permissions only for root and group)
systemctl start redis
systemctl enable redis
