#!/usr/bin/env python

"""
Creates a swarm of a manager and two hosts
"""

import docker
import subprocess
import requests
import sys
import os
import time
import re

vm_mem = '1024'
#vm_mem = '8192'
vm_cpu = '1'
#vm_cpu = '2'

docker_machine_version = '0.9.0'
#boot2iso_url = 'https://github.com/boot2docker/boot2docker/releases/download/v1.13.1-rc1/boot2docker.iso'
#experimental_boot2docker_url=https://hub.docker.com/r/ahbeng/boot2docker-experimental/
#Use local to make it faster
boot2iso_url= './boot2docker.iso'
system,node,release,version,machine = os.uname()

def color_print(color, text):
    """ Takes a color and some text and print the encoded text to terminal """
    if color == 'red':
        print('\x1b[6;30;41m' + text + '\x1b[0m')
    elif color == 'yellow':
        print('\x1b[6;30;43m' + text + '\x1b[0m')
    elif color == 'green':
        print('\x1b[6;30;42m' + text + '\x1b[0m')

def install_docker_machine():
    versioncommand = subprocess.Popen(['/usr/local/bin/docker-machine', 'version'], stdout=subprocess.PIPE)
    version = versioncommand.stdout.read().split()
    if not version[0] == 'docker-machine':
        print "ERROR: docker-machine not installed, install the docker-toolbox package first then rerun this script.\nhttps://github.com/docker/toolbox/releases"
        sys.exit(0)
    if not version[2].replace(",","") == docker_machine_version:
        print "WARNING: Found old version installing docker-machine v" + docker_machine_version
        url =  'https://github.com/docker/machine/releases/download/v' + docker_machine_version + '/docker-machine-' + sys.platform + '-' + machine
        request = requests.get(url, stream=True)
        with open('docker-machine', 'w') as file:
            for chunk in request.iter_content(chunk_size=1024):
                if chunk: # filter out keep-alive new chunks
                    file.write(chunk)
        subprocess.Popen(['chmod', 'a+x', 'docker-machine'], stdout=subprocess.PIPE)
        subprocess.Popen(['cp', '-f', 'docker-machine', '/usr/local/bin/docker-machine'], stdout=subprocess.PIPE)
        time.sleep(5)
    else:
        print "Found correct version of docker-machine installed"

def delete_old():
    print "Removing any old VM's"
    envcommand = subprocess.Popen(['/usr/local/bin/docker-machine', 'ls', '-q'], stdout=subprocess.PIPE)
    if envcommand:
        env = envcommand.stdout.read().split()
        for old in env:
            print "removing " + old
            rmcommand = subprocess.Popen(['/usr/local/bin/docker-machine', 'rm', '-y', old], stdout=subprocess.PIPE)
            rm = rmcommand.stdout.read()
            print rm
    else:
        print "No VM's running"

def create_vm(name):
    print "Creating virtual machine " + name
    createcommand = subprocess.Popen(['docker-machine', 'create', '-d', 'virtualbox', '--virtualbox-boot2docker-url' , boot2iso_url, '--virtualbox-memory', vm_mem, '--virtualbox-cpu-count', vm_cpu, '--engine-env', 'DOCKER_TLS=no', '--engine-opt', 'host=tcp://0.0.0.0:4243', '--engine-opt', 'experimental=true', name], stdout=subprocess.PIPE)
    print createcommand.stdout.read()


def get_client(ip):
    return docker.DockerClient(base_url='tcp://'+ ip + ':4243', version='auto', tls=False)

def get_ip(name):
    ipcommand = subprocess.Popen(['docker-machine', 'ip', name], stdout=subprocess.PIPE)
    ip = ipcommand.stdout.read()
    return ip.strip()

# swarm.init is broken because of a bug in docker-py : https://github.com/docker/docker-py/pull/1412
#def start_swarm(client, ip):
#    return client.swarm.init(
#        advertise_addr='192.168.99.100:2377', listen_addr='0.0.0.0:5000', force_new_cluster=True
#    )

def start_swarm(ip):
    print "STARTING SWARM ON :" + ip
    regex = re.compile('SWMTKN-.*')
    os.environ['DOCKER_HOST'] = 'tcp://' + ip + ':4243'
    subprocess.Popen(['docker', 'swarm', 'leave', '--force'])
    time.sleep(3)
    result = subprocess.Popen(['docker', 'swarm', 'init', '--advertise-addr', ip], stdout=subprocess.PIPE)
    token = [x for x in result.stdout.read().split() if regex.match(x) ]
    if token:
        print "Swarm init complete: \n TOKEN = " + str(token[0])
    return str(token[0])

def join_swarm(ip, token):
    print "JOINING WORKER " + ip + " TO SWARM"
    os.environ['DOCKER_HOST'] = 'tcp://' + ip + ':4243'
    subprocess.Popen(['docker', 'swarm', 'leave', '--force'])
    time.sleep(3)
    result = subprocess.Popen(['docker', 'swarm', 'join', '--token', token, get_ip("manager") + ':2377'], stdout=subprocess.PIPE )
    print result.stdout.read()

def ls_swarm(ip):
    print "SWARM CONFIGURATION:"
    os.environ['DOCKER_HOST'] = 'tcp://' + ip + ':4243'
    result = subprocess.Popen(['docker', 'node', 'ls'], stdout=subprocess.PIPE )
    print result.stdout.read()

# Verify docker-machine version
install_docker_machine()

# Delete old VM's
delete_old()

# Create VM's
create_vm("manager")
create_vm("node1")
create_vm("node2")
create_vm("node3")

# Start Swarm
token = start_swarm(get_ip("manager"))
join_swarm(get_ip("node1"), token)
join_swarm(get_ip("node2"), token)
join_swarm(get_ip("node3"), token)

#ls Swarm
ls_swarm(get_ip("manager"))
