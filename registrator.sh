#!/bin/bash
echo "Start registrator on the swarm"
export DOCKER_HOST=tcp://$(docker-machine ip swarm-master):4243
echo "docker run -d --name=reg --net=host --volume=/var/run/docker.sock:/tmp/docker.sock gliderlabs/registrator:latest consul://$(docker-machine ip consul):8500"
#docker run -d --name=reg --net=host --volume=/var/run/docker.sock:/tmp/docker.sock gliderlabs/registrator:latest -internal consul://$(docker-machine ip consul):8500
docker run -d -v /var/run/docker.sock:/tmp/docker.sock --name=reg -h $(docker-machine ip node0) gliderlabs/registrator:latest consul://$(docker-machine ip consul):8500 




