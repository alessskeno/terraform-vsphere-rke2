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
  - path: /etc/multipath.conf
    content: |
      defaults {
          user_friendly_names yes
      }
      blacklist {
          devnode "^sd[a-z0-9]+"
      }

  - path: /etc/cloud/templates/hosts.debian.tmpl
    content: |
      127.0.0.1 localhost
      127.0.1.1 $fqdn $hostname

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

packages:
  - vim
  - sudo
  - epel-release
  - bind-utils
  - nfs-kernel-server
  - net-tools

bootcmd:
 - printf "[Resolve]\nDNS=8.8.8.8 8.8.4.4" > /etc/systemd/resolved.conf
  - [ systemctl, restart, systemd-resolved ]

runcmd:
  - [ sh, -c, 'systemctl restart multipathd.service' ]
  - [ sh, -c, 'sysctl -p' ]
  - [ sh, -c, '/home/devops/install_node_exporter.sh' ]
  - [ sh, -c, 'mkdir -p /mnt/nfs_share' ]
  - [ sh, -c, 'chown nobody:nogroup /mnt/nfs_share' ]
  - [ sh, -c, 'chmod 777 /mnt/nfs_share' ]
  - [ sh, -c, 'exportfs -a' ]
  - [ sh, -c, 'systemctl restart nfs-kernel-server' ]

