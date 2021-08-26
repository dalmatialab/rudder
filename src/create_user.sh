#!/bin/bash

# Get ENV variables and use them for creating user
username=$RUDDER_USER
password=$(echo -n $RUDDER_PASSWORD | md5sum | cut -f1 -d ' ' )
role=$RUDDER_ROLE

# Create user configuration file
echo "<authentication hash='"md5"'>
    <user name='$username' password='$password' role='$role' />
</authentication>" > rudder-users.xml

# Copy user configuration file to server configuration directory
cp -f rudder-users.xml /opt/rudder/etc/rudder-users.xml
rm rudder-users.xml

# Restart server
systemctl restart rudder-jetty
