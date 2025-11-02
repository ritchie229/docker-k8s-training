#!/bin/bash
#read -p "Pls specify the NameSpace: " namespace

sysctl net.ipv4.ip_forward=1

namespace=$(kubectl get ns | grep -oE '\b(prod|dev)\b' | head -n1)
PORT=$(kubectl describe svc -n $namespace | grep NodePort | awk '{print $3}' | awk -F'/' '{printf $1}')
CLUSTER_IP=$(minikube ip)

iptables -t nat -A PREROUTING -p tcp --dport 30000 -j DNAT --to-destination $CLUSTER_IP:$PORT
echo "$CLUSTER_IP:$PORT accessible"

iptables -t nat -L PREROUTING -n --line-numbers

