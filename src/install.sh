#!/bin/bash

# Change permissions for mounted directory
sudo chmod -R 700 /var/rudder/cfengine-community/ppkeys

# Declare array whose elements are paths of mounted directories. Check if they are empty, if not, mount them to temporary file
allpaths=("/var/rudder/cfengine-community/ppkeys/" "/var/rudder/configuration-repository/" "/opt/rudder/etc/" "/var/rudder/ldap/openldap-data/" "/usr/share/postgresql/12/")
declare -a containsdata
for i in "${allpaths[@]}"
do
        if [ "$(ls -A $i)" ];then
                echo "Mounting $i to /tmp$i"
                mkdir -p "/tmp$i"
                mount --bind "/tmp$i" "$i"
		containsdata+=($i)
                chmod -R 700 /tmp/var/rudder/cfengine-community/ppkeys
        else
                echo "Mounted directories are empty."
        fi
done

# Install rudder server
sudo DEBIAN_FRONTEND=noninteractive apt-get update
sudo DEBIAN_FRONTEND=noninteractive apt-get -yq install rudder-server-root

# Execute script for creating user
bash create_user.sh


if (( ${#containsdata[@]} != 0 )); then

# Disable and stop systemctl services used by rudder
	rudder agent disable
	systemctl disable rudder-jetty rudder-relayd rudder-slapd postgresql apache2 cron
	systemctl stop rudder-jetty rudder-relayd rudder-slapd postgresql apache2 cron rudder-agent

# Check if there are any mounted paths, if there are any, unmount them.
	for y in "${containsdata[@]}"
	do
        	if [ -d "/tmp$y" ]; then
                	echo "Unmounting $y from /tmp$y"
                	umount $y
        	fi
	done

# Enable and start systemctl services used by rudder
	rudder agent enable
	systemctl enable rudder-jetty rudder-relayd rudder-slapd postgresql apache2 cron
	systemctl start dock rudder-jetty rudder-relayd rudder-slapd postgresql apache2 cron rudder-agent

fi

# If mounted directories are not empty, it will take 3-7 minutes before starting server !!
