#!/bin/sh

new_imap_user () {
  if [ "$#" -ne 2 ]; then
    echo "Please give user and password!"
    exit 1
  fi
  NETWORK_ADAPTER=eth0

  echo "~> Getting netmask for $NETWORK_ADAPTER."

  NET_CIDR=$(ipcalc "$(ip -s -o address show dev $NETWORK_ADAPTER | grep '"'"'inet '"'"' | awk '"'"'{ print $4 }'"'"')" | grep Network | awk '"'"'{ print $2 }'"'"')
  PASSWORD=$(doveadm pw -p "$2")
  echo "$1:$PASSWORD::::::allow_nets=$NET_CIDR" | sudo tee /etc/dovecot/users > /dev/null
}
