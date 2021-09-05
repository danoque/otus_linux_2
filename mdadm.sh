#!/bin/bash

install_mdadm() {
     yum -y install mdadm
}

configure_raid6() {
     mdadm --create --verbose /dev/md0 -l 6 -n 5 /dev/sd{b,c,d,e,f}
}

check_raid() {
     cat /proc/mdstat
     mdadm -D /dev/md0
}

save_raid() {
     mdadm --detail --scan --verbose
     echo "DEVICE partitions" > /etc/mdadm.conf
     bash -c "mdadm --detail --scan --verbose | awk '/ARRAY/ {print}' >> /etc/mdadm.conf"
}

create_part() {
     parted -s /dev/md0 mklabel gpt
     parted /dev/md0 mkpart primary ext4 0% 20%
     parted /dev/md0 mkpart primary ext4 20% 40%
     parted /dev/md0 mkpart primary ext4 40% 60%
     parted /dev/md0 mkpart primary ext4 60% 80%
     parted /dev/md0 mkpart primary ext4 80% 100%
     for i in $(seq 1 5); do sudo mkfs.ext4 /dev/md0p$i; done
     mkdir -p /raid/part{1,2,3,4,5}
     for i in $(seq 1 5); do mount /dev/md0p$i /raid/part$i; done
}

detail_raid() {
    mdadm --detail /dev/md0
}

main() {
  install_mdadm
  configure_raid6
  check_raid
  save_raid
  create_part
}

[[ "$0" == "$BASH_SOURCE" ]] && main "$@"
