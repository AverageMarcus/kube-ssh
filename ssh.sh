#!/usr/bin/env bash

NAMESPACE="$(kubectl config view --minify --output 'jsonpath={..namespace}' &>/dev/null)"
set -e
NAMESPACE=${NAMESPACE:-default}
POD="kube-ssh"
NODE=""

print_usage() {
  echo "kube-ssh - gain access to a Kubernetes host node (ssh-like for when a host doesn't have ssh)"
  echo " "
  echo "Usage:"
  echo "kube-ssh [options]"
  echo " "
  echo "Options:"
  echo "-h, --help            show this help text"
  echo "-n, --namespace       the namespace to launch the pod in"
  echo "-p, --pod             the name of the pod to launch (default: kube-ssh)"
  echo "-N, --node            the name of the node to access"
}

while test $# -gt 0; do
  case "$1" in
    -n|--namespace)
      shift
      NAMESPACE=$1
      shift
      ;;
    -p|--pod)
      shift
      POD=$1
      shift
      ;;
    -N|--node)
      shift
      NODE=$1
      shift
      ;;
    -h|--help)
      print_usage
      exit 0
      ;;
    *)
      break
      ;;
  esac
done

if [[ "$NODE" == "" ]]; then
  NODES=$(kubectl get nodes --no-headers -o custom-columns=name:.metadata.name)

  if [ -z "$(which fzf)" ]; then
    i=0
    while read -r node; do
      echo "[$i] - $node"
      i=$((i+1))
    done <<< "$NODES"
    read -p "Which node would you like to connect to? " -r
    echo ""
    IFS=$'\n' NODES=($NODES)
    NODE=${NODES[$REPLY]}
  else
    NODE=$(echo "$NODES" | fzf)
  fi
fi

NODE_NAME=$(kubectl get node $NODE -o template --template='{{index .metadata.labels "kubernetes.io/hostname"}}')
NODE_SELECTOR='"nodeSelector": { "kubernetes.io/hostname": "'${NODE_NAME}'" },'

kubectl run --namespace ${NAMESPACE} $POD --rm -it --image alpine --privileged --overrides '{"spec":{'"${NODE_SELECTOR}"'"hostPID": true}}' --command nsenter -- --mount=/proc/1/ns/mnt -- /bin/bash
