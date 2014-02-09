#!/bin/sh

set -e

SUDO=''
if [ `id -u` != "0" ]; then
    SUDO='sudo'
fi

RUN_UPDATE=true
RUN_IPT=true
RUN_SSH=true


###################
## Update system ##
###################

if $RUN_UPDATE ; then

$SUDO apt-get update -q
$SUDO apt-get upgrade -qy

echo "You probably also want to run 'apt-get dist-upgrade && reboot'"

fi

##############
## iptables ##
##############

if $RUN_IPT ; then

$SUDO apt-get install iptables-persistent

$SUDO cp /etc/iptables/rules.v6 /etc/iptables/rules.v6.backup
cat <<EOF | $SUDO tee /etc/iptables/rules.v6 > /dev/null
*filter

:INPUT DROP [0:0]
:FORWARD DROP [0:0]
:OUTPUT DROP [0:0]

COMMIT
EOF

$SUDO cp /etc/iptables/rules.v4 /etc/iptables/rules.v4.backup
cat <<EOF | $SUDO tee /etc/iptables/rules.v4 > /dev/null
*filter

:INPUT DROP [0:0]
:FORWARD DROP [0:0]
:OUTPUT DROP [0:0]

# Accept any related or established connections
-I INPUT  1 -m state --state RELATED,ESTABLISHED -j ACCEPT
-I OUTPUT 1 -m state --state RELATED,ESTABLISHED -j ACCEPT

# Allow all traffic on the loopback interface
-A INPUT  -i lo -j ACCEPT
-A OUTPUT -o lo -j ACCEPT

# Allow outbound DHCP request
-A OUTPUT -p udp --dport 67:68 --sport 67:68 -j ACCEPT

# Outbound DNS lookups
-A OUTPUT -o eth0 -p udp -m udp --dport 53 -j ACCEPT

# Outbound PING requests
-A OUTPUT -p icmp -j ACCEPT

# Outbound Network Time Protocol (NTP) request
-A OUTPUT -p udp --dport 123 --sport 123 -j ACCEPT

# SSH
-A INPUT  -i eth0 -p tcp -m tcp --dport 22 -m state --state NEW -j ACCEPT

# Outbound HTTP
-A OUTPUT -o eth0 -p tcp -m tcp --dport 80 -m state --state NEW -j ACCEPT
-A OUTPUT -o eth0 -p tcp -m tcp --dport 443 -m state --state NEW -j ACCEPT

COMMIT
EOF

$SUDO ip6tables-restore /etc/iptables/rules.v6
$SUDO iptables-restore /etc/iptables/rules.v4

fi

#########
## SSH ##
#########

if $RUN_SSH ; then

mkdir -p ~/.ssh
chmod 700 ~/.ssh

TMPFILE=`mktemp`

cat > $TMPFILE <<EOF
# Replace this line with your public ssh key (see 'man ssh-keygen' on how to obtain one)
EOF

"${EDITOR:-vi}" $TMPFILE
cat $TMPFILE >> ~/.ssh/authorized_keys
chmod 644 ~/.ssh/authorized_keys

fi

# vim: tabstop=4 shiftwidth=4 softtabstop=4 expandtab autoindent
