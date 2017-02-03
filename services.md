Services
---
In Docker a service is a designation for a number of tasks making up a logical unit of functionality in a cluster.
Services are defined in compose or bundle files or can be created at runtime. 

**Show services running in the swarm**
```bash
% docker service ls
ID            NAME             MODE        REPLICAS  IMAGE
0gwr9mns5yvy  Test1_service2   replicated  1/1       busybox:latest
ixizb8p9v3wd  Test1_service4   replicated  1/1       busybox:latest
jolgnp418clq  Test1_service10  replicated  1/1       busybox:latest
k11ofqzti42w  Test1_service7   replicated  1/1       busybox:latest
mcq2qyzzf16v  Test1_service9   replicated  1/1       busybox:latest
mojzyzli0qai  Test1_service5   replicated  1/1       busybox:latest
pe47f8fcl0cm  Test1_service1   replicated  1/1       busybox:latest
qugejun8i51h  Test1_service6   replicated  1/1       busybox:latest
uq3uq1xwivce  Test1_service8   replicated  1/1       busybox:latest
zmshti88mmq1  Test1_service3   replicated  1/1       busybox:latest
```

**Show logs for a service**
```bash
% docker service logs Test1_service1
Test1_service1.1.qkvc8iuhehcm@node2    | --- service2 ping statistics ---
Test1_service1.1.qkvc8iuhehcm@node2    | 1 packets transmitted, 1 packets received, 0% packet loss
Test1_service1.1.qkvc8iuhehcm@node2    | round-trip min/avg/max = 0.044/0.044/0.044 ms
Test1_service1.1.qkvc8iuhehcm@node2    | PING service2 (10.0.0.4): 56 data bytes
Test1_service1.1.qkvc8iuhehcm@node2    | 64 bytes from 10.0.0.4: seq=0 ttl=64 time=0.039 ms
```

**Inspect a service**
```bash
% docker service inspect Test1_service1 --pretty
ID:		pe47f8fcl0cmpbuwmu1wprt1c
Name:		Test1_service1
Labels:
 com.docker.stack.namespace=Test1
Service Mode:	Replicated
 Replicas:	1
Placement:
ContainerSpec:
 Image:		busybox:latest@sha256:817a12c32a39bbe394944ba49de563e085f1d3c5266eb8e9723256bc4448680e
 Args:		/bin/ash -c sleep 1; while true; do ping -c 1 service2; sleep 2; done
Resources:
Networks: sf7eg4spbsgn4kggwy046qb4n
Endpoint Mode:	vip
```
Without _--pretty_ you get a full information

**Show which nodes are running a service**
```bash
% docker service ps EXAMPLE_STACK_1_service1
ID            NAME                        IMAGE           NODE   DESIRED STATE  CURRENT STATE               ERROR  PORTS
q3rw0t89onxn  EXAMPLE_STACK_1_service1.1  busybox:latest  node3  Running        Running about a minute ago 

```

**Remove a service**
```bash
% docker service rm Test1_service1
Test1_service1
```


