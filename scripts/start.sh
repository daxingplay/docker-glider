#!/bin/bash

echo "Activating iptables rules..."
/srv/firewall.sh start

pid=0

# SIGUSR1 handler
usr_handler() {
  echo "usr_handler"
}

# SIGTERM-handler
term_handler() {
    if [ $pid -ne 0 ]; then
        echo "Term signal catched. Shutdown glider and disable iptables rules..."
        kill -SIGTERM "$pid"
        wait "$pid"
        /srv/firewall.sh stop
    fi
    exit 143; # 128 + 15 -- SIGTERM
}

# setup handlers
trap 'kill ${!}; usr_handler' SIGUSR1
trap 'kill ${!}; term_handler' SIGTERM

echo "Starting redsocks..."
/srv/glider/glider -config /srv/glider/config &
pid="$!"

# wait indefinetely
while true
do
    tail -f /dev/null & wait ${!}
done