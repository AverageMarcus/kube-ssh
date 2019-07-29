#!/bin/sh
set -e

NODES=$(kubectl get nodes --no-headers -o custom-columns=name:.metadata.name)
i=0
while read -r node; do
  echo "[$i] - $node"
  i=$((i+1))
done <<< "$NODES"
read -p "Which node would you like to connect to? " -r
echo ""
IFS=$'\n' NODES=($NODES)
NODE_NAME=$(kubectl get node ${NODES[$REPLY]} -o template --template='{{index .metadata.labels "kubernetes.io/hostname"}}')
NODE_SELECTOR='"nodeSelector": { "kubernetes.io/hostname": "'${NODE_NAME}'" },'

kubectl run kube-ssh --restart=Never -it --rm --image overriden --overrides '
{
  "spec": {
    "hostPID": true,
    "hostNetwork": true,
    '"${NODE_SELECTOR}"'
    "tolerations": [{
      "operator": "Exists"
    }],
    "containers": [
      {
        "name": "kube-ssh",
        "image": "averagemarcus/kube-ssh:latest",
        "stdin": true,
        "tty": true,
        "securityContext": {
          "privileged": true
        }
      }
    ]
  }
}' --attach "$@"
