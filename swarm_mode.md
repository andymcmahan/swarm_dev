# Swarm-Mode

### New Concepts

##### Swarm
* A swarm is a cluster of one or more **workers** and **manager** **nodes** attached together using the cluster management features embedded in docker-engine.
    * A manager node dispatches service **tasks** to the nodes participating in the cluster. For reliability there can be many manager nodes in a swarm cluster, a single manager is elected as the swarm leader.
    * A worker node takes **tasks** from the manager and schedules them to run locally.

    ![Overview:][swarm]

[swarm]: http://lucjuggery.com/blog/wp-content/uploads/2016/07/q5ZcSVcr06OuoljzvFbsvrnTzqrqzN7Y9aBZTaXoQ8Q.png "swarm"

#### Stack
* A stack is a collection of services that make up an application in a specific environment.
    * A docker stack can be defined in a 'bundle file' or a 'compose file' > version '3'. 

#### Service
* A service is the definition of the tasks to execute on the worker nodes.
    * Replicated services model - swarm manager distributes a number of replica tasks among the worker nodes based on the set scale for the service.
    * Global services model - swarm runs one task for each service on each node in the cluster.

#### Load Balancing
* Swarm-mode has built in ingress load balancing for exposed services. docker will balance requests to published ports through to replicated internal services automatically.
 
![ingress][load_balance]
 
[load_balance]: http://docs.docker.com.s3-website-us-east-1.amazonaws.com/engine/swarm/images/ingress-routing-mesh.png "ingress"
 
 
#### [Nodes](nodes.md)
#### [Stacks](stacks.md)
#### [Services](services.md)
#### [Compose_V3](compose.md)