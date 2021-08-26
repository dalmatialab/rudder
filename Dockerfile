FROM jrei/systemd-ubuntu:20.04

LABEL maintainer="dalmatialab"

# Install tools 
RUN apt-get update -y && apt-get install -y default-jre wget gnupg lsb-release sudo locales

# Get rudder installation package
RUN wget --quiet -O- "https://repository.rudder.io/apt/rudder_apt_key.pub" | apt-key add -
RUN echo "deb http://repository.rudder.io/apt/6.2/ $(lsb_release -cs) main" > /etc/apt/sources.list.d/rudder.list

# Declare ENV variables for creating user
ENV RUDDER_USER="rudderserver" RUDDER_PASSWORD="rudderserver" RUDDER_ROLE="administrator"

# Add script for installing rudder
ADD ./src/install.sh /usr/sbin/install.sh
RUN chmod a+x /usr/sbin/install.sh
ADD ./src/create_user.sh /usr/sbin/create_user.sh
RUN chmod a+x /usr/sbin/create_user.sh 
ADD ./src/entrypoint.service /etc/systemd/system/entrypoint.service
RUN systemctl enable entrypoint.service

