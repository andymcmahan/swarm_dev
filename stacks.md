Stacks
---
In Docker a stack is a collection of services making up a logical application or unit of functionality. Stacks are defined as bundle files or compose files and named/tagged at runtime.
The **_docker stack_** command can be run on any manager node. 

**Deploy a new stack to the swarm**
```bash
% docker stack deploy -c overlay-ping.yml Test_Stack
Creating network Test_Stack_overlay_test
Creating service Test_Stack_service6
Creating service Test_Stack_service4
Creating service Test_Stack_service1
Creating service Test_Stack_service8
Creating service Test_Stack_service10
Creating service Test_Stack_service5
Creating service Test_Stack_service9
Creating service Test_Stack_service3
Creating service Test_Stack_service7
Creating service Test_Stack_service2
```
In Docker > 1.13.1 you can shortcut with **_docker deploy -c compose_filename.yml_**

**Show stacks running in the swarm**
```bash
% docker stack ls
NAME        SERVICES
Test_Stack  10
```

**Remove a stack**
```bash
% docker stack rm Test_Stack
Removing service Test_Stack_service1
Removing service Test_Stack_service5
Removing service Test_Stack_service4
Removing service Test_Stack_service3
Removing service Test_Stack_service9
Removing service Test_Stack_service6
Removing service Test_Stack_service8
Removing service Test_Stack_service7
Removing service Test_Stack_service2
Removing service Test_Stack_service10
Removing network Test_Stack_overlay_test
```

**Show services within a stack**
```bash
% docker stack services Test_Stack
ID            NAME                  MODE        REPLICAS  IMAGE
01gbsjpq750f  Test_Stack_service1   replicated  1/1       busybox:latest
5alcf6ydq3qj  Test_Stack_service6   replicated  1/1       busybox:latest
8mb7gdf28663  Test_Stack_service5   replicated  1/1       busybox:latest
gxi0wvtsd0n8  Test_Stack_service4   replicated  1/1       busybox:latest
kcz05dxi9lag  Test_Stack_service9   replicated  1/1       busybox:latest
nyyew3ti8n9i  Test_Stack_service3   replicated  1/1       busybox:latest
qhxdl6tlil2t  Test_Stack_service10  replicated  1/1       busybox:latest
sxcfc9tklw2p  Test_Stack_service8   replicated  1/1       busybox:latest
v3g95wf2akug  Test_Stack_service2   replicated  1/1       busybox:latest
zcrbu2fvxtky  Test_Stack_service7   replicated  1/1       busybox:latest
```
10 services in this stack named 'service[1-10]'

**Show all tasks within a stack**
```bash
% docker stack ps Test_Stack
ID            NAME                       IMAGE           NODE     DESIRED STATE  CURRENT STATE                ERROR                             PORTS
s0dt10hnj7w4  Test_Stack_service6.1      busybox:latest  manager  Running        Running 39 seconds ago
mkir23mnw0t2   \_ Test_Stack_service6.1  busybox:latest  manager  Shutdown       Failed 45 seconds ago        "starting container failed: Ad…"
74mh79zpseh7   \_ Test_Stack_service6.1  busybox:latest  node1    Shutdown       Rejected 55 seconds ago      "failed to allocate gateway (1…"
```



