Nodes
---
In Docker a 'node' is a logical host that is participating in the swarm. A node can be a **worker** or a **manager** and by default both node types participate in the swarm.
Nodes will run containers associated with a **service** as assigned by a swarm manager. 

**Show status of the swarm from any manager node**
```bash
% docker info
Swarm: active
 NodeID: 4s75prjrk4w2ifmyy5idvgivx
 Is Manager: true
 ClusterID: kdcmdl8j1gxp3onhsde0ncrbu
 Managers: 1
 Nodes: 4
```

Using the **_docker node_** command the swarm nodes can be manipulated directly.
This command is only applicable onlt when DOCKER_HOST is set to any manager node. 

**Show current swarm configuration listing all swarm nodes**
```bash
% docker node ls
ID                           HOSTNAME  STATUS  AVAILABILITY  MANAGER STATUS
98bbk8ax3llw29qdqlc1urwiy *  manager   Ready   Active        Leader
gq9hh71gxzz801l56zvemtz5s    node3     Ready   Active
h7vz5m08qo7p2h9wgy8totsyi    node2     Ready   Active
zutm5ez91iryc1qui1kf559cw    node1     Ready   Active
```
Here we have only 1 manager node named 'manager'

**Show all services running on a specific node**
```bash
% docker node ps node1
ID            NAME              IMAGE           NODE   DESIRED STATE  CURRENT STATE           ERROR  PORTS
w9xpeiopmrgu  test_service5.1   busybox:latest  node1  Running        Running 11 minutes ago
nw96hplvzpyr  test_service10.1  busybox:latest  node1  Running        Running 11 minutes ago
xucbrlz93syf  test_service9.1   busybox:latest  node1  Running        Running 11 minutes ago
```
Using **_docker node ps_** without a parameter shows all services running on the manager

**Status of a specific a node**
```bash
% docker node inspect --pretty node1
ID:			t9vbilop0p3910kpir7cp52np
Hostname:		node1
Joined at:		2017-02-02 20:02:41.469772559 +0000 utc
Status:
 State:			Ready
 Availability:		Active
 Address:		192.168.99.101
Platform:
 Operating System:	linux
 Architecture:		x86_64
```
See the status of the node under **'Availability:'**

**Drain the node**
```bash
% docker node update --availability drain node1
node1

% docker node inspect --pretty node1
ID:			t9vbilop0p3910kpir7cp52np
Hostname:		node1
Joined at:		2017-02-02 20:02:41.469772559 +0000 utc
Status:
 State:			Ready
 Availability:		Drain

% docker node ps node1
ID            NAME              IMAGE           NODE   DESIRED STATE  CURRENT STATE            ERROR  PORTS
w9xpeiopmrgu  test_service5.1   busybox:latest  node1  Shutdown       Shutdown 3 seconds ago
```
The drained nodes services are now running on another node...

```bash
% docker service ps test_service5
ID            NAME                 IMAGE           NODE   DESIRED STATE  CURRENT STATE           ERROR  PORTS
vtvdylzj4y7n  test_service5.1      busybox:latest  node2  Running        Running 3 minutes ago
w9xpeiopmrgu   \_ test_service5.1  busybox:latest  node1  Shutdown       Shutdown 3 minutes ago
```

**Remove the node from the swarm**
```bash
% docker node rm --force node1
node1
% docker node ls
ID                           HOSTNAME  STATUS  AVAILABILITY  MANAGER STATUS
4pf372m8u2xoz6oa883k5lyur    node2     Ready   Active
4s75prjrk4w2ifmyy5idvgivx *  manager   Ready   Active        Leader
ra5h8uufukz795clqrt2mcrsh    node3     Ready   Active
```
Only use **_docker node rm_** to remove a node that is down (not connected) and never use it to remove a manager. 
**Always 'demote' a manager first**
You can use **_docker node rm --force_** to remove a worker node from the swarm then on the individual node use:
**_docker swarm leave_**

**Promote/Demote worker/manager nodes**
```bash
% docker node promote node1
Node node1 promoted to a manager in the swarm.

% docker node ls
ID                           HOSTNAME  STATUS  AVAILABILITY  MANAGER STATUS
4pf372m8u2xoz6oa883k5lyur    node2     Ready   Active
4s75prjrk4w2ifmyy5idvgivx *  manager   Ready   Active        Leader
n80lz46z9yg20crhyqmlqkgul    node1     Ready   Active        Reachable
ra5h8uufukz795clqrt2mcrsh    node3     Ready   Active

% docker node demote manager
Manager manager demoted in the swarm.

% docker node ls
ID                           HOSTNAME  STATUS  AVAILABILITY  MANAGER STATUS
4pf372m8u2xoz6oa883k5lyur    node2     Ready   Active
4s75prjrk4w2ifmyy5idvgivx    manager   Ready   Active
n80lz46z9yg20crhyqmlqkgul *  node1     Ready   Active        Leader
ra5h8uufukz795clqrt2mcrsh    node3     Ready   Active
```

