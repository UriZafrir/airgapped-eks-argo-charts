## content:
1. aws alb controller pointing to ingress-nginx for routing multiple ingresses
2. ingress nginx with allow-insecure for argo cd
3. argo cd with ingress and insecure - meaning it will receive http after terminating ssl at ALB.
4. argocd-image-updater
5. a solution to add external git repo to code pipelines.
6. an example declarative app-of-apps which deploys two argocd charts. to be deployed with
```
kubectl apply -f /infra/argo-charts/root-app
```
This is the code for the secrets:
```
argocd-image-updater require generic secrets:

kubectl create secret generic git-ssh-key-secret \
    --from-file=sshPrivateKey=~/.ssh/id_rsa \
    -n argocd

kubectl create secret generic apps-secret     --from-file=.dockerconfigjson=/home/ec2-user/config.json     --type=kubernetes.io/dockerconfigjson   --namespace=argocd


#https://kubernetes.io/docs/tasks/configure-pod-container/pull-image-private-registry/
kubectl create secret generic apps-secret \
    --from-file=.dockerconfigjson=/home/ec2-user/config.json \
    --type=kubernetes.io/dockerconfigjson
```









### this is the code to replace public images with your own
```
docker pull registry.k8s.io/ingress-nginx/controller:v1.10.1
docker pull registry.k8s.io/ingress-nginx/kube-webhook-certgen:v1.4.1


docker tag ee54966f3891 <your-private-registry>/ingress-nginx-controller:v1.10.1
docker tag 684c5ea3b61b <your-private-registry>/ingress-nginx-kube-webhook-certgen:v1.4.1

#first create repo in ECR
#login
aws ecr get-login-password --region il-central-1 | docker login --username AWS --password-stdin <your-private-registry>
#then
docker push <your-private-registry>/ingress-nginx-controller:v1.10.1
docker push <your-private-registry>/ingress-nginx-kube-webhook-certgen:v1.4.1




docker pull quay.io/argoproj/argocd
docker pull ghcr.io/dexidp/dex
docker pull public.ecr.aws/docker/library/redis

docker tag 8df93f598b46 <your-private-registry>/dexidp/dex:v2.38.0
docker tag b8b1d1e1c83b <your-private-registry>/argoproj/argocd:v2.11.4
docker tag 9c893be668ac <your-private-registry>/docker/library/redis:7.2.4-alpine

docker push <your-private-registry>/dexidp/dex:v2.38.0
docker push <your-private-registry>/argoproj/argocd:v2.11.4
docker push <your-private-registry>/docker/library/redis:7.2.4-alpine


docker pull public.ecr.aws/eks/aws-load-balancer-controller:v2.8.1
docker tag 1c1ffbad9ef2 <your-private-registry>/eks/aws-load-balancer-controller:v2.8.1
docker push <your-private-registry>/eks/aws-load-balancer-controller:v2.8.1



docker pull quay.io/argoprojlabs/argocd-image-updater
docker tag 3d7e131f1431 <your-private-registry>/argoprojlabs/argocd-image-updater:v0.14.0
docker push <your-private-registry>/argoprojlabs/argocd-image-updater:v0.14.0
```