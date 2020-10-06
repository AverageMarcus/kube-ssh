# kube-ssh

Get shell access to a Kubernetes host instance. The pod will be removed upon exiting.

## Usage

```shell
➜ sh -c "$(curl -sSL https://raw.githubusercontent.com/AverageMarcus/kube-ssh/master/ssh.sh)"
[0] - ip-10-189-21-146.eu-west-1.compute.internal
[1] - ip-10-189-21-234.eu-west-1.compute.internal
[2] - ip-10-189-21-96.eu-west-1.compute.internal
Which node would you like to connect to? 1

If you don't see a command prompt, try pressing enter.
[root@ip-10-189-21-234 ~]#
```

### fzf

If you have [fzf](https://github.com/junegunn/fzf) available on your PATH it will be used instead of needing to enter the number of the node you'd like to connect to.
