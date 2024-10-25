#cloud-config
groups:
  - ubuntu: [root,sys]
  - devops

users:
  - default
  - name: devops
    primary_group: devops
    groups: sudo
    sudo: "ALL=(ALL) NOPASSWD:ALL"
    lock_passwd: false
    passwd: ${hashed_pass}
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
      127.0.1.1 $fqdn
      ${harbor_host} ${harbor_domain}
      ${lb_ip} ${env}-rke2.${domain}

bootcmd:
  - printf "[Resolve]\nDNS=8.8.8.8 8.8.4.4" > /etc/systemd/resolved.conf
  - [ systemctl, restart, systemd-resolved ]

runcmd:
  - [ sh, -c, 'systemctl restart multipathd.service' ]
  - [ sh, -c, 'sysctl -p' ]
  - [ sh, -c, 'systemctl enable --now iscsid.service' ]
  - [ bash, -c, 'echo alias k="kubectl" >> ~/.bashrc' ]

