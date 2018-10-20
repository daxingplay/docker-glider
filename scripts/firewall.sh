#!/bin/bash

##########################
# Setup the Firewall rules
##########################
fw_setup() {
  #iptables -F -t nat

  ipset create glider hash:net

  iptables -P INPUT ACCEPT
  iptables -P FORWARD ACCEPT

  iptables -t nat -A POSTROUTING -s 192.168.0.0/24 -j MASQUERADE

  iptables -t nat -N GLIDER

  while read item; do
      iptables -t nat -A GLIDER -d $item -j RETURN
  done < /srv/glider/config/whitelist.txt

#   iptables -t nat -I PREROUTING -p tcp -m set --match-set glider dst -j REDIRECT --to-ports 1081
#   iptables -t nat -I OUTPUT -p tcp -m set --match-set glider dst -j REDIRECT --to-ports 1081
  iptables -t nat -A GLIDER -p tcp -j REDIRECT --to-ports 1081
  iptables -t nat -A PREROUTING -p tcp -j GLIDER
  iptables -t nat -A OUTPUT -p tcp -j GLIDER
}

##########################
# Clear the Firewall rules
##########################
fw_clear() {
  iptables-save | grep -v GLIDER | iptables-restore
  ipset destroy glider
  #iptables -L -t nat --line-numbers
  #iptables -t nat -D PREROUTING 2
}

case "$1" in
    start)
        echo -n "Setting firewall rules..."
        fw_clear
        fw_setup
        echo "done."
        ;;
    stop)
        echo -n "Cleaning firewall rules..."
        fw_clear
        echo "done."
        ;;
    *)
        echo "Usage: $0 {start|stop}"
        exit 1
        ;;
esac
exit 0