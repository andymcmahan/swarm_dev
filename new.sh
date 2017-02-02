#!/bin/bash

clear
echo $(pwd)
DOCKER_MACHINE_VERSION="0.8.2"
. functions
. try_step_next

install_machine() {
  echo "installing docker machine version - ${DOCKER_MACHINE_VERSION}"
  $(curl -L https://github.com/docker/machine/releases/download/v${DOCKER_MACHINE_VERSION}/docker-machine-`uname -s`-`uname -m` >/usr/local/bin/docker-machine && chmod a+x /usr/local/bin/docker-machine)
}

install_machine
