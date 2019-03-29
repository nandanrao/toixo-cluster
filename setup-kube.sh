
# Manually:
# Create cluster in UI
# Run:
# gcloud --project $PROJECT compute addresses create $CLUSTER_NAME-ip --region europe-west1

PROJECT=toixotoixo
CLUSTER_NAME=toixo-cluster
STATIC_IP=34.76.183.123

# gcloud container clusters create my-regional-cluster --num-nodes 2 --region europe-west1 \
# --node-locations europe-west1-b,europe-west1-c

gcloud --project $PROJECT container clusters get-credentials --region europe-west1 $CLUSTER_NAME

# Setup Tiller with proper RBAC service account
kubectl create -f rbac-config.yaml
helm init --service-account tiller

# This is necessary for NGINX INGRESS (maybe?) and LOCAL SSD PROVISIONER
kubectl create clusterrolebinding cluster-admin-binding --clusterrole cluster-admin --user $(gcloud config get-value account)

# Install nginx-ingress
helm install stable/nginx-ingress --name nginx-ingress --set rbac.create=true --set controller.service.loadBalancerIP=$STATIC_IP

# Setup cert-manager
helm install --name cert-manager stable/cert-manager

# Create cluster-issuer
kubectl create -f cm-issuer.yaml
