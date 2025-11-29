#!/bin/bash
#echo "=================LOCKING IP FORWARDING====================="
#iptables -C DOCKER-USER -i ens160 -m conntrack --ctstate DNAT -j ACCEPT 2>/dev/null && \
#iptables -D DOCKER-USER -i ens160 -m conntrack --ctstate DNAT -j ACCEPT


#read -p "Enter NS: " namespace

#sysctl -w net.ipv4.ip_forward=0
#sysctl -w net.ipv4.conf.all.route_localnet=0

namespace=$(kubectl get ns | grep -oE '\b(prod|dev)\b' | head -n1)
PORT=$(kubectl describe svc -n $namespace | grep NodePort | awk '{print $3}' | awk -F'/' '{printf $1}')
CLUSTER_IP=$(minikube ip --profile minihelm)
echo "===========REMOVING IP FORWARDING MAIN RULES==============="
iptables -t nat -D PREROUTING -p tcp --dport 30001 -j DNAT --to-destination $CLUSTER_IP:$PORT
#iptables -t nat -D OUTPUT -p tcp --dport 30001 -j DNAT --to-destination $CLUSTER_IP:$PORT
#iptables -t nat -D POSTROUTING -d $CLUSTER_IP -p tcp --dport $PORT -j MASQUERADE
#iptables -t nat -D POSTROUTING -j MASQUERADE


#echo "=============DOCKER UNLOCKED IP FORWARDING================="
#iptables -L DOCKER-USER -nv --line-numbers
echo "==============$CLUSTER_IP:$PORT CLOSED!!!=================="
iptables -t nat -L PREROUTING -n --line-numbers
#iptables -t nat -L OUTPUT -n --line-numbers
#iptables -t nat -L POSTROUTING -n --line-numbers



