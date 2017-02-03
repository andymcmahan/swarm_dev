Compose Version '3'
---
Docker swarm-mode is designed to deploy 'stacks' defined in docker compose files of version '3'.

* Version "3" no longer supports the 'volumes_from:' parameter. Use the top level volumes definition and attach all containers to the top level volume.
  * [Docker volumes in compose reference](https://docs.docker.com/compose/compose-file/#/volume-configuration-reference)

* Version "3" no longer supports the hardware definitions: _cpu_shares, cpu_quota, cpuset, mem_limit, memswap_limit_. Use The resources key under deploy instead
  * [Swarm-mode resources reference](https://docs.docker.com/compose/compose-file/#resources) 
  
* Version "3" add the deploy section to allow configuration related to the deployment and running of services on a swarm.
  * [docker compose fiile deploy reference](https://docs.docker.com/compose/compose-file/#/deploy)
  * "constraints" must now be defined under the 'placement' sub section of 'deploy'
   
##### Example Compose Version '3' file:
This stack deploys 2 services: service1 and service2 
* service1 runs in replicated mode (the default mode for compose v3) with only a single replication instance, meaning only one copy of the container will be started.
    * The service also uses and constraint of 'node.role==manager' so the single task will run only on a manager node.
    * The update_config section below defines how docker will deal with rolling service updates, parallelism is how many containers to update at a time, delay is the delay between updates
    The process for rolling updates is defined here: [roling_updates](https://docs.docker.com/engine/swarm/swarm-tutorial/rolling-update/)
      
* service 2 runs in global mode - This mean that one container will be started on each node in the swarm. 10 nodes then 10 containers will be started.

```yml
version: '3'
networks:
  overlay_test:
    driver: overlay

services:
  service1:
    image: busybox
    command: '/bin/ash -c "sleep 1; while true; do ping -c 1 service2; sleep 2; done"'
    networks:
      - overlay_test
    deploy:
      replicas: 1
      update_config:
        parallelism: 1
        delay: 30s
      restart_policy:
        condition: none
      placement:
        constraints:
          - node.role == manager

  service2:
    image: busybox
    command: '/bin/ash -c "sleep 2; while true; do ping -c 1 service1; sleep 2; done"'
    networks:
      - overlay_test
    deploy:
      mode: global
```