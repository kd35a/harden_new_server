# Hardening new server
Script for setting up and securing new Ubuntu servers. This is not an attempt to
make your server totally secure, but just hardening it so it isn't an open
playground for anyone.

## Goal
Automate what Spenser Jones describes in his [blog post][spenserj], and other
good recommendations on what should be done to have a somewhat secure system.
Automate what is possible, to lower the bar for a secure server, and make it
repeatable.

## What it does
* updates your system
* sets up iptables with some reasonable defaults, and iptables-persistent
* adds your public ssh key, so you can authenticate using it

## TODO
* set up [unattended-upgrades][unattended-upgrades]
* `sed` `/etc/ssh/sshd_config` to only allow a certain user, pubkey-auth and
  other nice stuff
* add a user to admin/sudo group if not already done (what is recommended here?)

## Future
* [Port knocking to access ssh][portknock]

[unattended-upgrades]: https://help.ubuntu.com/community/AutomaticSecurityUpdates#Using_the_.22unattended-upgrades.22_package
[spenserj]: http://spenserj.com/blog/2013/07/15/securing-a-linux-server/
[portknock]: https://digitalocean.com/community/articles/how-to-configure-port-knocking-using-only-iptables-on-an-ubuntu-vps
