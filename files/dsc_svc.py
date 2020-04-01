#!/usr/bin/python3
import requests
import json
import os
import subprocess

# GET NAME OF THIS NODE
process = subprocess.run(['hostname'], stdout=subprocess.PIPE, universal_newlines=True)
node_name = process.stdout.strip()

# GET ENVIRONMENT THIS NODE BELONGS TO
node_name_parts = node_name.split('.')
node_env = node_name_parts[1]

f = open("/usr/local/mcollect/environment.cfg", "w")
f.write(node_env+'\n')
f.close()

# QUERY AMBARI API FOR CURRENT SERVICES RUNNING ON THIS NODE
r = requests.get('http://ambari000.management.skyfall.io:8080/api/v1/clusters/'+node_env.upper()+'/hosts/'+node_name+'/host_components', auth=('admin', 'admin'))
j = r.json()

# WRITE ROLE INTO profile.cfg ON SERVICE MATCH
f = open("/usr/local/mcollect/profile.cfg", "w")
for item in j['items']:
    if item['HostRoles']['component_name'] == "NAMENODE":
        f.write('hdfs-namenode\n')
    elif item['HostRoles']['component_name'] == "SECONDARY_NAMENODE":
        f.write('hdfs-snamenode\n')
    elif item['HostRoles']['component_name'] == "DATANODE":
        f.write('hdfs-datanode\n')
    elif item['HostRoles']['component_name'] == "ZOOKEEPER_SERVER":
        f.write('zookeeper-server\n')
    elif item['HostRoles']['component_name'] == "HISTORYSERVER":
        f.write('mapreduce2-historyserver\n')
f.close()

# CLONE OR PULL SMOKE TESTS FROM REPOSITORY MATCHING ENVIRONMENT
if not os.path.exists('/usr/local/mcollect/tests'):
    os.makedirs('/usr/local/mcollect/tests')
    process = subprocess.run(['git','clone','--single-branch','--branch', node_env, 'https://github.com/thevictorgreen/devopsify-hdp-configtest.git', '/usr/local/mcollect/tests'], stdout=subprocess.PIPE, universal_newlines=True)
    print(process.stdout)
else:
    process = subprocess.run(['git','--git-dir=/usr/local/mcollect/tests/.git','pull'], stdout=subprocess.PIPE, universal_newlines=True)
    print(process.stdout)
