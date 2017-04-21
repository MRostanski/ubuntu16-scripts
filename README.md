# ubuntu16-scripts

Various scripts for stack installations on my personal favourite, Ubuntu 16.04 LTS Server.

## EC2 scripts

These are scripts for running on fresh EC2 installations based on Ubuntu 16.04 (especially pasting into userdata when creating new EC2s).

Those can be used on normal machine as well, just remember to ```sudo su``` first.

 * [Syslog Configuration for systemd custom services](aws/rsyslog_conf.sh)
 * [Node.js LTS 6.x Installation](aws/nodejs_lts.sh)
 * [MongoDB 3.2 Installation](aws/mongodb.sh)
 * [Redis Installation](aws/redis.sh)

 * [Full MEAN stack](aws/mean_stack.sh)
