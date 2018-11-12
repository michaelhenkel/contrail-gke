# Contrail on k8s using Helm
## Pre-requisites
### A k8s cluster supporting SkyDNS.    
GKE example:    
```
gcloud container clusters create contrail-cluster --machine-type n1-standard-16 --cluster-version latest
```
### Helm
see: https://docs.helm.sh/using_helm/#installing-helm    
## Instructions
### Clone repo
```
git clone https://github.com/michaelhenkel/gke
cd contrail-gke/helm
```
### Init helm
```
kubectl apply -f create-helm-service-account.yaml
helm init --service-account helm
```
### Install Contrail
```
helm install ./Contrail
```

## Access Cluster
### Get WebUI Service IP
```
kubectl -n contrail get service contrailwebui-svc -o=jsonpath='{.status.loadBalancer.ingress[*].ip}'
```

### Browser
Open browser with https://externalIP:8143    
