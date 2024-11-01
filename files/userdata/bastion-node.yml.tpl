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

  - path: /home/devops/install_node_exporter.sh
    permissions: '0755'
    content: |
      #!/bin/bash
      wget https://github.com/prometheus/node_exporter/releases/download/v1.8.2/node_exporter-1.8.2.linux-amd64.tar.gz
      tar -xvf node_exporter-1.8.2.linux-amd64.tar.gz
      cd node_exporter-1.8.2.linux-amd64
      sudo cp node_exporter /usr/local/bin
      useradd --no-create-home --shell /bin/false node_exporter
      chown node_exporter:node_exporter /usr/local/bin/node_exporter
      systemctl enable  --now node_exporter

  - path: /home/devops/install_devops_tools.sh
    permissions: '0755'
    content: |
      #!/bin/bash
      wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
      echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
      curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
      sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
      sudo apt update
      sudo apt install -y python3-pip terraform sshpass whois
      sudo pip3 install ansible ansible-core

bootcmd:
  - printf "[Resolve]\nDNS=8.8.8.8 8.8.4.4" > /etc/systemd/resolved.conf
  - [ systemctl, restart, systemd-resolved ]

runcmd:
  - [ sh, -c, '/home/devops/install_node_exporter.sh' ]
  - [ sh, -c, '/home/devops/install_devops_tools.sh' ]
  - [ bash, -c, 'echo "export KUBECONFIG=${rke2_download_kubeconf_path}/rke2.yaml" >> ~/.bashrc' ]
  - [ bash, -c, 'echo alias k="kubectl" >> ~/.bashrc' ]
