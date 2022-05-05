#!/bin/bash
echo "updater host";
/usr/bin/apt-get update > /dev/null;
/usr/bin/apt-get full-upgrade -y;
/usr/bin/apt-get autoremove -y > /dev/null;
echo;
echo "#############";
echo "#updater lxc#";
echo "#############";
echo;
for data in $(lxc-ls)
do
  echo "working on $data";
  if [[ $(/usr/bin/lxc-info $data -s) =~ "RUNNING" ]]
  then
    /usr/bin/lxc-attach $data -- /usr/bin/apt-get update > /dev/null;
    /usr/bin/lxc-attach $data -- /usr/bin/apt-get full-upgrade -y;
    /usr/bin/lxc-attach $data -- /usr/bin/apt-get autoremove -y > /dev/null;
    if test -f "/var/run/reboot-required";
    then
      echo "standby for host reboot";
    else
      if /usr/bin/lxc-attach $data -- /usr/bin/test -f "/var/run/reboot-required"
      then
        echo "reboot $data";
        /usr/bin/lxc-attach $data -- /usr/sbin/reboot;
      else
        echo "no reboot nedet for $data"
      fi
    fi
  else
    echo "offline";
  fi
done
if test -f "/var/run/reboot-required";
then
  echo "reboot HOST";
  /usr/sbin/reboot;
else
  echo "update complet";
  echo;
fi
