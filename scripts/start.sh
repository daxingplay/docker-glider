#!/bin/bash

if [ '$GLIDER_ONLY' != 'true' ]; then
    echo "Activating iptables rules..."
    /srv/firewall.sh start
fi

pid=0

# SIGUSR1 handler
usr_handler() {
  echo "usr_handler"
}

# SIGTERM-handler
term_handler() {
    if [ $pid -ne 0 ]; then
        echo "Term signal catched. Shutdown glider."
        kill -SIGTERM "$pid"
        wait "$pid"
        if [ '$GLIDER_ONLY' != 'true' ]; then
            echo "clean iptable rules..."
            /srv/firewall.sh stop
        fi
    fi
    exit 143; # 128 + 15 -- SIGTERM
}

# setup handlers
trap 'kill ${!}; usr_handler' SIGUSR1
trap 'kill ${!}; term_handler' SIGTERM

echo "Starting redsocks..."
/srv/glider/glider -config /srv/glider/config/glider.conf &
pid="$!"

# wait indefinetely
while true
do
    tail -f /dev/null & wait ${!}
done