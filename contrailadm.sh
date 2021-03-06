#!/bin/bash
OPTIND=1

#CLUSTER_VERSION="1.11.2-gke.9"
CLUSTER_VERSION="latest"
#ZONE="europe-west1-b"
MACHINE_TYPE="n1-standard-16"
USER=""
CLUSTER_NAME="contrail-cluster"
NAMESPACE="contrail"

while getopts "h?c:z:u:m:v:n:" opt; do
    case "$opt" in
    h|\?)
        show_help
        exit 0
        ;;
    c)  CLUSTER_NAME=$OPTARG
        ;;
    z)  ZONE=$OPTARG
        ;;
    u)  USER=$OPTARG
        ;;
    m)  MACHINE_TYPE=$OPTARG
        ;;
    v)  CLUSTER_VERSION=$OPTARG
        ;;
    n)  NAMESPACE=$OPTARG
        ;;
    esac
done

ACTION=${@:$OPTIND:1}

shift $((OPTIND-1))

[ "${1:-}" = "--" ] && shift

missing=""
if [[ ${ACTION} == "create" && -z ${USER} ]]; then
  missing+=" user (-u),"
fi

if [[ -z ${ACTION} ]]; then
  missing+=" ACTION"
fi

if [[ -n ${missing} ]]; then
  echo ${missing} is missing
  exit 1
fi

if [[ -n ${ZONE} ]]; then
  zone='--zone ${ZONE}'
fi

if [[ -n ${CLUSTER_VERSION} ]]; then
  cluster_version="--cluster-version ${CLUSTER_VERSION}"
fi

function createCluster(){
    cluster_exists=`gcloud container clusters list --filter NAME:${CLUSTER_NAME} ${zone}| wc -l`
    if [[ ${cluster_exists} -ne 0 ]]; then
        echo cluster already exists
    else
        gcloud container clusters create contrail-cluster --machine-type ${MACHINE_TYPE} ${zone} ${cluster_version}
    fi
}

function createRoleBindings(){
    if [[ `kubectl get rolebinding rabbitmq-rolebinding 2>/dev/null` ]]; then
        echo rolebinding already exists
    else
        kubectl create rolebinding rabbitmq-rolebinding \
		--clusterrole=admin --user=${USER} \
		-n ${NAMESPACE}
    fi
}

function createNamespace(){
    if [[ `kubectl get namespace ${NAMESPACE} 2>/dev/null` ]]; then
        echo namespace ${NAMESPACE} already exists
    else
        kubectl create namespace ${NAMESPACE}
    fi
}

function waitForPods(){
    echo "Waiting for ${1} PODs to be ready"
    while true
    do
	expectedReplicas=`kubectl get sts -n ${NAMESPACE} --selector app=${1} -o=jsonpath='{.items[*].spec.replicas}'`
	readyReplicas=`kubectl get sts -n ${NAMESPACE} --selector app=${1} -o=jsonpath='{.items[*].status.readyReplicas}'`
	if [[ ${expectedReplicas} == ${readyReplicas} ]]; then
            echo "${1} PODs are ready"
	    break
	fi
	sleep 2
    done
}
function createPods(){
    kubectl apply -f zookeeper.yaml
    kubectl apply -f cassandra.yaml
    kubectl apply -f rabbitmq.yaml
    waitForPods zk
    waitForPods rabbitmq
    waitForPods cassandra
    #kubectl apply -f kafka.yaml
    kubectl apply -f contrailconfig.yaml
    kubectl apply -f contrailwebui.yaml
    #waitForPods kafka
    waitForPods contrailconfig
    #kubectl apply -f contrailanalytics.yaml
    #waitForPods contrailanalytics
    kubectl apply -f contrailcontrol.yaml
    waitForPods contrailcontrol
}
function getExternalIP(){
  externalIP=`kubectl -n contrail get service contrailwebui-svc -o=jsonpath='{.status.loadBalancer.ingress[*].ip}'`
  while [[ -z ${externalIP} ]]; do
    sleep 2
    externalIP=`kubectl -n contrail get service contrailwebui-svc -o=jsonpath='{.status.loadBalancer.ingress[*].ip}'`
  done
  echo ${externalIP}
}

if [[ ${ACTION} == 'create' ]]; then
    createCluster
#    createNamespace
#    createRoleBindings
#    kubectl apply -f contrail-cm.yaml
#    createPods
#    externalIP=`getExternalIP`
#    echo "access webui at https://${externalIP}:8143"
fi
if [[ ${ACTION} == 'delete' ]]; then
    kubectl delete pods --all --now=true -n ${NAMESPACE}
    kubectl delete statefulset --all --grace-period=1 --force=true -n ${NAMESPACE}
    kubectl delete poddisruptionbudget --all -n ${NAMESPACE}
    kubectl delete service --all -n ${NAMESPACE}
    kubectl delete configmap --all -n ${NAMESPACE}
    kubectl delete rolebinding --all -n ${NAMESPACE}
    kubectl delete role --all -n ${NAMESPACE}
    kubectl delete serviceaccount --all -n ${NAMESPACE}
    kubectl delete pvc --all -n ${NAMESPACE}
    kubectl delete pv --all -n ${NAMESPACE}
    kubectl delete namespace ${NAMESPACE}
fi
