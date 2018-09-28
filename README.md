# contrail-gke
## clone git repo
```
git clone https://github.com/michaelhenkel/contrail-gke
cd contrail-gke
```
## kick it off
```
./contrailadm.sh -u <YOUR_GCP_USERID> create
```
## get rid of it
```
./contrailadm.sh -u <YOUR_GCP_USERID> delete
```

# Example
```
➜  contrail-gke git:(master) ✗ ./contrailadm.sh -u <MY_GCP_USERID> create
WARNING: Currently node auto repairs are disabled by default. In the future this will change and they will be enabled by default. Use `--[no-]enable-autorepair` flag  to suppress this warning.
WARNING: Starting in Kubernetes v1.10, new clusters will no longer get compute-rw and storage-ro scopes added to what is specified in --scopes (though the latter will remain included in the default --scopes). To use these scopes, add them explicitly to --scopes. To use the new behavior, set container/new_scopes_behavior property (gcloud config set container/new_scopes_behavior true).
Creating cluster contrail-cluster...done.
Created [https://container.googleapis.com/v1/projects/contrail-solutions-group/zones/europe-west4-a/clusters/contrail-cluster].
To inspect the contents of your cluster, go to: https://console.cloud.google.com/kubernetes/workload_/gcloud/europe-west4-a/contrail-cluster?project=contrail-solutions-group
kubeconfig entry generated for contrail-cluster.
NAME              LOCATION        MASTER_VERSION  MASTER_IP      MACHINE_TYPE    NODE_VERSION  NUM_NODES  STATUS
contrail-cluster  europe-west4-a  1.9.7-gke.6     35.204.123.69  n1-standard-16  1.9.7-gke.6   3          RUNNING
namespace "contrail" created
rolebinding.rbac.authorization.k8s.io "rabbitmq-rolebinding" created
configmap "contrail-cm" created
service "zk-svc" created
configmap "zk-cm" created
poddisruptionbudget.policy "zk-pdb" created
statefulset.apps "zk" created
service "cassandra" created
persistentvolume "cassandra-data-1" created
persistentvolume "cassandra-data-2" created
persistentvolume "cassandra-data-3" created
statefulset.apps "cassandra" created
serviceaccount "rabbitmq" created
role.rbac.authorization.k8s.io "endpoint-reader" created
rolebinding.rbac.authorization.k8s.io "endpoint-reader" created
service "rabbitmq" created
configmap "rabbitmq-config" created
statefulset.apps "rabbitmq" created
Waiting for zk PODs to be ready
zk PODs are ready
Waiting for rabbitmq PODs to be ready
rabbitmq PODs are ready
Waiting for cassandra PODs to be ready
cassandra PODs are ready
service "kafka-svc" created
statefulset.apps "kafka" created
poddisruptionbudget.policy "kafka-pdb" created
service "contrailconfig-svc" created
poddisruptionbudget.policy "contrailconfig-pdb" created
statefulset.apps "contrailconfig" created
service "contrailwebui-svc" created
poddisruptionbudget.policy "contrailwebui-pdb" created
statefulset.apps "contrailwebui" created
Waiting for kafka PODs to be ready
kafka PODs are ready
Waiting for contrailconfig PODs to be ready
contrailconfig PODs are ready
service "contrailanalytics-svc" created
poddisruptionbudget.policy "contrailanalytics-pdb" created
statefulset.apps "contrailanalytics" created
Waiting for contrailanalytics PODs to be ready
contrailanalytics PODs are ready
service "contrailcontrol-svc" created
poddisruptionbudget.policy "contrailcontrol-pdb" created
statefulset.apps "contrailcontrol" created
Waiting for contrailcontrol PODs to be ready
contrailcontrol PODs are ready
access webui at https://35.204.230.177:8143
```

