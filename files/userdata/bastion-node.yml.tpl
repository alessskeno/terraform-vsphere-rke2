#cloud-config
groups:
  - ubuntu: [root,sys]
  - devops
users:
  - default
  - name: devops
    primary_group: devops
    groups: sudo
    sudo: ['ALL=(ALL) NOPASSWD:ALL']
    lock_passwd: false
    passwd: "${hashed_pass}"
  - name: ci-user
    primary_group: ci-user
    groups: sudo
    sudo: "ALL=(ALL) NOPASSWD:ALL"
    lock_passwd: false
    passwd: ${hashed_pass}


manage_etc_hosts: true

write_files:
  - path: /etc/cloud/templates/hosts.debian.tmpl
    content: |
      127.0.0.1 localhost
      127.0.1.1 $fqdn
      ${lb_ip} ${env}-rancher.${domain}
      10.100.70.250 vcsa.hostart.local
%{ for index, endpoint in master_endpoints_az1 ~}
      ${endpoint} ${env}-az1-master-node-${index + 1}
%{ endfor ~}
%{ for index, endpoint in master_endpoints_az3 ~}
      ${endpoint} ${env}-az3-master-node-${index + 1}
%{ endfor ~}
%{ for index, endpoint in worker_endpoints_az1 ~}
      ${endpoint} ${env}-az1-worker-node-${index + 1}
%{ endfor ~}
%{ for index, endpoint in worker_endpoints_az3 ~}
      ${endpoint} ${env}-az3-worker-node-${index + 1}
%{ endfor ~}

  - path: /home/devops/install_devops_tools.sh
    permissions: '0755'
    content: |
      #!/bin/bash
      wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
      echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
      sudo apt update
      sudo apt install -y python3-pip terraform sshpass whois
      sudo pip3 install ansible ansible-core

bootcmd:
  - printf "[Resolve]\nDNS=8.8.8.8 8.8.4.4" > /etc/systemd/resolved.conf
  - [ systemctl, restart, systemd-resolved ]

runcmd:
  - [ sh, -c, '/home/devops/install_devops_tools.sh' ]
  - [ bash, -c, 'echo "export KUBECONFIG=${rke2_download_kubeconf_path}" >> ~/.bashrc' ]
  - [ bash, -c, 'echo "export PATH=$PATH:/var/lib/rancher/rke2/bin/" >> ~/.bashrc' ]
  - [ bash, -c, 'echo alias k="kubectl" >> ~/.bashrc' ]
