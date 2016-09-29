# swarm_dev

Quickly bring up a local docker swarm for prototyping on OSX or Linux without any TLS

---

Uses docker-machine (virtualbox) to bring up a docker swarm environment with discovery and without TLS to make testing quick.

The script starts the following hosts:
consul - handles discovery with consu at port 8500 
swarm-master - the single swarm manager
node0 - swarm node ready to take jobs (labeled node0)
node1 - swarm node ready to take jobs (labeled node1)

I found this made prototyping easier as configuring the docker daemon and container settings correctly to get a 'test' swarm up was taking more time then I thought reasonable.




