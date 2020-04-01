#!/usr/bin/python3

import requests
import json
import os
import subprocess

process = subprocess.run(['hostname'], stdout=subprocess.PIPE, universal_newlines=True)
node_name = process.stdout.strip()

node_name_parts = node_name.split('.')
node_env = node_name_parts[1]

r = requests.get('http://ambari000.management.skyfall.io:8080/api/v1/clusters/'+node_env.upper()+'/hosts/'+node_name+'/host_components', auth=('admin', 'admin'))
j = r.json()

for item in j['items']:
    print(item['HostRoles']['component_name'])
