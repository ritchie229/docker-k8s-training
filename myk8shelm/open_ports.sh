#!/bin/bash
echo "==========DOCKER USER ACCEPT IF DROPPED============"
iptables -C DOCKER-USER -i ens160 -m conntrack --ctstate DNAT -j ACCEPT 2>/dev/null || \
iptables -I DOCKER-USER -i ens160 -m conntrack --ctstate DNAT -j ACCEPT


#read -p "Pls specify the NameSpace: " namespace
echo "=================ENABLE IP FORWARDING=============="
sysctl -w net.ipv4.ip_forward=1
#sysctl -w net.ipv4.conf.all.route_localnet=1


namespace=$(kubectl get ns | grep -oE '\b(prod|dev)\b' | head -n1)
PORT=$(kubectl describe svc -n $namespace | grep NodePort | awk '{print $3}' | awk -F'/' '{printf $1}')
CLUSTER_IP=$(minikube ip --profile minihelm)
echo "=================ADD 30001 RULE===================="
iptables -t nat -A PREROUTING -p tcp --dport 30001 -j DNAT --to-destination $CLUSTER_IP:$PORT
#iptables -t nat -A OUTPUT -p tcp --dport 30001 -j DNAT --to-destination $CLUSTER_IP:$PORT
#iptables -t nat -A POSTROUTING -d $CLUSTER_IP -p tcp --dport $PORT -j MASQUERADE
#iptables -t nat -A POSTROUTING -j MASQUERADE

echo "===========DOCKER UNLOCKED IP FORWARDING==========="
echo "+++++++++++++++++++++see+++++++++++++++++++++++++++"
iptables -L DOCKER-USER -nv --line-numbers
echo "===========$CLUSTER_IP:$PORT accessible============"
echo "+++++++++++++++++++++see+++++++++++++++++++++++++++"
iptables -t nat -L PREROUTING -n --line-numbers
#iptables -t nat -L OUTPUT -n --line-numbers
#iptables -t nat -L POSTROUTING -n --line-numbers
