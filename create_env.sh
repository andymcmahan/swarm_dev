#!/bin/bash
clear
echo $(pwd)
DOCKER_MACHINE_VERSION="0.9.0"
. functions
. try_step_next

install_machine() {
  echo "installing docker machine version - ${DOCKER_MACHINE_VERSION}"
  $(curl -L https://github.com/docker/machine/releases/download/v${DOCKER_MACHINE_VERSION}/docker-machine-`uname -s`-`uname -m` >/usr/local/bin/docker-machine && chmod a+x /usr/local/bin/docker-machine)
}

switch_to_host() {
  export DOCKER_HOST=tcp://$(/usr/local/bin/docker-machine ip ${host}):2375
}

check_for_docker() {
  if  [ ! -e "/usr/local/bin/docker" ]
  then
    echo -e "\n\033[31mDocker for mac not found please install from here:\n https://download.docker.com/mac/stable/Docker.dmg\033[0m\n" && exit 1
  fi
}

check_for_machine() {
  if [ -e "/usr/local/bin/docker-machine" ]
  then
    current_version=$(/usr/local/bin/docker-machine version | awk '{print $3}' | sed 's/,//g')
    echo -e "\n\033[93mINFO: current version: v${current_version}\033[0m\n"
    if [ "$current_version" != "$DOCKER_MACHINE_VERSION" ]
    then
      install_machine
    fi
  else
    install_machine
  fi
}

vm_exists() {
  if [ $(/usr/local/bin/docker-machine ls | grep ${host} | awk '{print $1}') ]
  then
    echo -e "\n" && docker-machine rm -y ${host}
  fi
}

vm_consul() {
  echo -e "\n"
  docker-machine create -d virtualbox --engine-env DOCKER_TLS=no --engine-opt host=tcp://0.0.0.0:2375 ${host} || true
  sleep 3
}

vm_manage() {
    echo -e "\n"
      docker-machine create -d virtualbox --engine-env DOCKER_TLS=no --engine-opt host=tcp://0.0.0.0:2375 --engine-opt="cluster-store=consul://$(/usr/local/bin/docker-machine ip consul):8500" --engine-opt="cluster-advertise=eth0:2375" --engine-label="host=${host}" "${host}" || true
      sleep 3
}

vm_create() {
  echo -e "\n"
  docker-machine create -d virtualbox --virtualbox-memory "2048" --virtualbox-cpu-count "1" --engine-env DOCKER_TLS=no --engine-opt host=tcp://0.0.0.0:2375 --engine-opt="cluster-store=consul://$(/usr/local/bin/docker-machine ip consul):8500" --engine-opt="cluster-advertise=eth0:2375" --engine-label="host=${host}" "${host}" || true
  sleep 3
}

docker_consul() {
  echo -e "\n" && switch_to_host
  sed -i.bak s/ipaddress/$(/usr/local/bin/docker-machine ip consul)/g consul-compose.yml   
  docker-compose -f consul-compose.yml up -d 
  cp -f consul-compose.yml.bak consul-compose.yml && mv consul-compose.yml.bak consul-compose.previous
  sleep 3
}

docker_swarm() {
  echo -e "\n" && switch_to_host
  export DOCKER_HOST=tcp://$(/usr/local/bin/docker-machine ip swarm-master):2375
  docker run -d -p 4243:2375 swarm manage -H 0.0.0.0:2375 consul://$(/usr/local/bin/docker-machine ip consul):8500
  sleep 3
}

docker_join() {
  echo -e "\n" && switch_to_host
  docker run -d swarm join --advertise $(/usr/local/bin/docker-machine ip ${host}):2375 consul://$(/usr/local/bin/docker-machine ip consul):8500
  sleep 3
}

docker_portainer() {
    echo -e "\n" && switch_to_host
    docker run -d -p 9000:9000 portainer/portainer -H tcp://$(docker-machine ip swarm-master):4243 
    sleep 3
}

### STEPS ###
step "Check for Docker"
  try check_for_docker
next && echo -e "\n\033[93mINFO: Docker version : $(docker version | grep -m 1 Version | awk '{print $2}')\033[0m\n" 

step "Check for docker-machine"
  try check_for_machine
next && echo -e "\n" 

step "Start consul vm"
  host="consul"
  try vm_exists
  try vm_consul
next && echo -e "\n\033[93mINFO: Consul is up at: http://$(docker-machine ip consul):8500\033[0m\n"

step "Start consul container"
  try docker_consul
next && echo -e "\n"

step "Start swarm-master vm"
  host="swarm-master"
  try vm_exists
  try vm_manage
next && echo -e "\n"

step "Start swarm container"
  try docker_swarm
next && echo -e "\n\033[93mINFO: docker-swarm is on tcp://$(docker-machine ip swarm-master):4243\033[0m\n"

step "Start swarm node0 vm"
  host="node0"
  try vm_exists
  try vm_create
next && echo -e "\n"

step "Join swarm node0"
  try docker_join
next && echo -e "\n"

step "Start swarm node1 vm"
  host="node1"
  try vm_exists
  try vm_create
next && echo -e "\n"

step "Join swarm node1"
  try docker_join
next && echo -e "\n"

echo -e "\033[93mINFO: consul - tcp://$(docker-machine ip consul):2375\033[0m" 
echo -e "\033[93mINFO: swarm-master - tcp://$(docker-machine ip swarm-master):2375\033[0m" 
echo -e "\033[93mINFO: node0 - tcp://$(docker-machine ip node0):2375\033[0m" 
echo -e "\033[93mINFO: node1 - tcp://$(docker-machine ip node1):2375\033[0m"

