#!/bin/bash

### Prepare exercises environment for servera and serverb.
### Create by hualf on 2020-08-10.

function servera_env_conf() {
  # Configure Apache httpd server to test SELinux port
  echo "---> Configure Apache httpd server to test SELinux port..."
  echo "--> Install Apache httpd package..."
  yum install -y httpd
  cat > /etc/httpd/conf.d/vhost.conf << EOF
Listen 82
<VirtualHost *:82>
  DocumentRoot  /var/www/html
  ServerName  servera.lab.example.com
</VirtualHost>
EOF
  echo "RHCSAv8.0 exercise." > /var/www/html/index.html
  
  if `systemctl start httpd.service > /dev/null`; then
    echo -e "[\033[32m*\033[0m] Apache httpd server start successfully..."
  else
    echo -e "[\033[31m*\033[0m] Apache httpd server start ERROR..."
    systemctl status httpd.service
  fi
  
  # Change NTP server for servera
  echo "---> Change NTP server for servera..."
  sed -i '/172.25.254.254/d' /etc/chrony.conf
  systemctl restart chronyd.service

  # Create jary user account and files
  echo "---> Create jary user account and files..."
  useradd -u 2005 jary && echo redhat | passwd --stdin jary
  for DEST in /tmp /usr/local /usr/share /var/lib; do cp /etc/services ${DEST}; done
  for FILE in /tmp/services /usr/local/services /usr/share/services /var/lib/services; do 
    chown jary ${FILE}
  done

  # Change yum repository for servera
  echo "---> Change yum repository for servera..."
  cp /etc/yum.repos.d/rhel_dvd.repo /etc/yum.repos.d/rhel_dvd.repo.bak
  rm -f /etc/yum.repos.d/rhel_dvd.repo

  # Change network for servera
  echo "---> Change network for servera..."
  NETWORK_CONFIG=/etc/sysconfig/network-scripts/ifcfg-Wired_connection_1
  cp ${NETWORK_CONFIG} ${NETWORK_CONFIG}.bak
  sed -i 's/172.25.250.10/172.25.250.15/' ${NETWORK_CONFIG}
  sed -i 's/172.25.250.254/172.25.250.250/' ${NETWORK_CONFIG}
  sed -i 's/lab/domain/' /etc/hostname
  echo "--> Reload servera network..."
  nmcli connection reload
  nmcli connection down Wired\ connection\ 1
  nmcli connection up Wired\ connection\ 1
}

function serverb_env_conf() {
  # Change yum repository for serverb
  echo "---> Change yum repository for serverb..."
  cp /etc/yum.repos.d/rhel_dvd.repo /etc/yum.repos.d/rhel_dvd.repo.bak
  rm -f /etc/yum.repos.d/rhel_dvd.repo  

  # Create /dev/vdb partition
  echo "---> Create /dev/vdb partition..."
  parted -s /dev/vdb mklabel msdos
  parted -s /dev/vdb mkpart primary xfs 2048s 513M
  echo "--> Print /dev/vdb partition table..."
  parted /dev/vdb print

  # Create lvdata logical volume
  echo "---> Create lvdata logical volume..."
  pvcreate /dev/vdb1
  vgcreate vgdata /dev/vdb1
  lvcreate -L 192M vgdata -n lvdata

  # Verify current block device
  echo "---> Verify current block device..."
  lsblk

  echo "---> Make ext4 filesystem for lvdata..."
  mkfs.ext4 /dev/vgdata/lvdata

  echo "---> Mount /dev/vgdata/lvdata block device..."
  mkdir /extend
  echo "/dev/vgdata/lvdata  /extend  ext4  defaults  0 0" >> /etc/fstab
  mount -a
  df -Th
}

case $1 in
  servera)
    echo ">>> Configure `hostname -a` exersise environment <<<"
    if [ `hostname -a` == "servera" ]; then	    
      servera_env_conf
    else
      echo -e " * \033[31mERROR\033[0m: please check NODE name"
      echo " * Current node: `hostname -a`"
    fi	    
    ;;
  serverb)
    echo ">>> Configure `hostname -a` exersise environment <<<"
    if [ `hostname -a` == "serverb" ]; then
      serverb_env_conf
    else
      echo -e " * \033[31mERROR\033[0m: check NODE name"
      echo " * Current node: `hostname -a`"
    fi	    
    ;;
  *)
    echo "Usage: bash RHCSAv8.0-env-prepare.sh [servera|serverb]"
    ;;
esac


