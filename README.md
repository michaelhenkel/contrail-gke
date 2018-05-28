# contrail-gke
## clone git repo
```
git clone https://github.com/michaelhenkel/contrail-gke
cd contrail-gke
```
## create cluster
```
gcloud container clusters create contrail-cluster \
  --machine-type "n1-standard-4" \
  --zone "europe-west1-b"
  --cluster-version "1.10.2-gke.3"
```
## create role binding
```
GKE_USER_ID=YOUR_GKE_USER_ID
kubectl create rolebinding rabbitmq-rolebinding --clusterrole=admin --user=${GKE_USER_ID}
```
## create db cluster
```
kubectl apply -f zookeeper.yaml
kubectl apply -f kafka.yaml
kubectl apply -f cassandra.yaml
kubectl apply -f rabbitmq_rbac.yaml
kubectl apply -f rabbitmq.yaml
```
