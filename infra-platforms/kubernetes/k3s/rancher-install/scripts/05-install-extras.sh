#!/usr/bin/env bash

# Definir colores para la salida de terminal
BLUE="\033[1;34m"
GREEN="\033[1;32m"
NC="\033[0m"

echo -e "${GREEN}Extras installation.....${NC}"
sudo apt install -y bind9
echo -e "${BLUE}bind  installed.....${NC}"

cd /etc/bind
echo -e "${GREEN}Configuring bind.....${NC}"
sudo cat <<EOF >named.conf.local
zone "marcomarco.blog" {
    type master;
    file "/etc/bind/db.marcomarco.blog";
};

// zona reversa
zone "192.-in.addr.arpa" {
    type master;
    file "/etc/bind/db.192";
};
EOF
echo -e "${BLUE}named.conf.local  created.....${NC}"
sudo cat named.conf.local


MY_IP=$(hostname -I | awk '{print $1}')
RANCHER_CONTROL_PLANE=$(cat /tmp/hostentries | grep "rancher-control-plane" | awk '{print $1}')
RANCHER_NODE1=$(cat /tmp/hostentries | grep "rancher-node1" | awk '{print $1}')


sudo cat <<EOF >db.marcomarco.blog
\$TTL    604800
@       IN      SOA     marcomarco.blog. root.marcomarco.blog. (
                              2         ; Serial
                         604800         ; Refresh
                          86400         ; Retry
                        2419200         ; Expire
                         604800 )       ; Negative Cache TTL
;
@       IN      NS      marcomarco.blog.
@       IN      A       $MY_IP
rancher-control-plane IN      A       $RANCHER_CONTROL_PLANE
rancher-node1    IN      A       $RANCHER_NODE1
*.rancher IN      A       $RANCHER_CONTROL_PLANE
*.rancher IN      A       $RANCHER_NODE1
EOF
echo -e "${BLUE}db.marcomarco.blog  created.....${NC}"
sudo cat db.marcomarco.blog

LAST_IP=$(hostname -I | awk '{print $1}' | awk 'BEGIN { FS="." } { print $4 }')
PRE_LAST_IP=$(hostname -I | awk '{print $1}' | awk 'BEGIN { FS="." } { print $3 }')
ANTE_PRE_LAST_IP=$(hostname -I | awk '{print $1}' | awk 'BEGIN { FS="." } { print $2 }')

sudo cat <<EOF >db.192
$TTL    604800
@       IN      SOA     marcomarco.blog. root.marcomarco.blog. (
                              1         ; Serial
                         604800         ; Refresh
                          86400         ; Retry
                        2419200         ; Expire
                         604800 )       ; Negative Cache TTL
;
@       IN      NS      marcomarco.blog.
$LAST_IP.$PRE_LAST_IP.$ANTE_PRE_LAST_IP       IN      PTR     marcomarco.blog.
EOF
echo -e "${BLUE}db.192  created.....${NC}"
sudo cat db.192

sudo systemctl restart bind9 && \
sudo systemctl status bind9
echo -e "${BLUE}bind9 installed!!!${NC}"
