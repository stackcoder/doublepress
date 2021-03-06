#!/bin/bash
set -euo pipefail

name="$(basename $BASH_SOURCE)"
lock="/var/run/${name}.lock"
fifo="/var/run/${name}.fifo"
#lock="./${name}.lock"
#fifo="./${name}.fifo"

exec 200>"${lock}"
if ! flock -n 200; then
  # slave instance, notify master
  echo "1" > "${fifo}"
  exit 0
fi

# master instance, owns lock
echo $$ 1>&200

# create fifo
rm -f "${fifo}" && mkfifo "${fifo}"

# cleanup fifo and lock file on exit
trap "rm \"${fifo}\" && rm \"${lock}\"" EXIT

# wait for slave instances signaling button press
counter=1
for i in {1..10}; do
  if read -t 0.5 signal; then
    echo -n '+' && ((counter+=1))
  else
    echo -n '.'
  fi
done <>"${fifo}"

echo "($counter)"
case $counter in
  2)
    logger "doublepress: Suspend"
    systemctl restart getty@tty?
    systemctl suspend
    ;;
  3)
    logger "doublepress: Poweroff"
    systemctl poweroff
    ;;
  *)
    logger "doublepress: Reject accidental Power-Button press"
    ;;
esac
