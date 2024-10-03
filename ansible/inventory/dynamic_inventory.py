#!/usr/bin/env python3
import json
import subprocess

# Use terraform output to fetch instance IPs
terraform_output = subprocess.check_output(['terraform', 'output', '-json'])
instances = json.loads(terraform_output)

inventory = {
    'all': {
        'hosts': instances['instance_ips']['value'],
        'vars': {
            'ansible_user': 'ubuntu',
            'ansible_ssh_private_key_file': '~/.ssh/qiross.pem',
        }
    }
}

print(json.dumps(inventory, indent=2))
