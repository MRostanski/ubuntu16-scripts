#!/bin/bash
# 
# ubuntu16-scripts by mrostanski
#
# rSyslog configuration for systemd custom services - enable udp, add a sender, add a source, restart syslog
#
# Usage: run as root or insert into EC2 userdata
#

sed -i '/^#.*module(load="imudp")/s/^#//' /etc/rsyslog.conf
sed -i '/^#.*input(type="imudp" port="514")/s/^#//' /etc/rsyslog.conf
sed -i '/type="imudp" port="514"/a $AllowedSender UDP, 127.0.0.1' /etc/rsyslog.conf
sed -i -e 's/\*\.\*;auth,authpriv.none/\*\.\*;auth,authpriv.none;local2.none/g' /etc/rsyslog.d/50-default.conf
systemctl restart rsyslog
echo "Rsyslog reconfigured"