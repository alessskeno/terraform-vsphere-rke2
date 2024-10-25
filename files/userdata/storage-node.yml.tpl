#cloud-config
groups:
  - ubuntu: [root,sys]
  - devops
manage_etc_hosts: true

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
      ${harbor_host} ${harbor_domain}
      ${lb_ip} ${env}-rke2.${domain}

bootcmd:
  - printf "[Resolve]\nDNS=8.8.8.8 8.8.4.4" > /etc/systemd/resolved.conf
  - [ systemctl, restart, systemd-resolved ]

runcmd:
  - [ sh, -c, 'systemctl restart multipathd.service' ]
  - [ sh, -c, 'sysctl -p' ]
  - [ sh, -c, 'mkdir -p /var/lib/longhorn' ]
  - [ sh, -c, 'parted --script -a optimal -- /dev/sdb mklabel gpt mkpart primary 512MiB -1' ]
  - [ sh, -c, 'sleep 60' ]
  - [ sh, -c, 'mkfs.ext4 /dev/sdb1' ]
  - [ sh, -c, 'sleep 30' ]
  - [ sh, -c, 'e2label /dev/sdb1 "${storage_fs_label}"' ]
  - [ sh, -c, 'echo "LABEL=${storage_fs_label} /var/lib/longhorn ext4 rw,noatime 0 2" | tee -a /etc/fstab' ]
  - [ sh, -c, 'mount /var/lib/longhorn' ]