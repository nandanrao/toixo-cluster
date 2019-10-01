
# Manually:
# Create cluster in UI
# Run:
# gcloud --project $PROJECT compute addresses create $CLUSTER_NAME-ip --region europe-west1

PROJECT=toixotoixo
CLUSTER_NAME=india
STATIC_IP=35.200.140.234
ZONE=asia-south1-b

gcloud --project $PROJECT container clusters get-credentials --zone $ZONE $CLUSTER_NAME

# Setup Tiller with proper RBAC service account
kubectl create -f rbac-config.yaml

sudo helm init --service-account tiller --wait

# This is necessary for NGINX INGRESS (maybe?) and LOCAL SSD PROVISIONER
kubectl create clusterrolebinding cluster-admin-binding --clusterrole cluster-admin --user $(gcloud config get-value account)

# Install nginx-ingress
sudo helm install stable/nginx-ingress --name nginx-ingress --set rbac.create=true --set controller.service.loadBalancerIP=$STATIC_IP

# -------------------------------
# Setup cert-manager
# --------------------------------

kubectl apply -f https://raw.githubusercontent.com/jetstack/cert-manager/release-0.10/deploy/manifests/00-crds.yaml

# Create the namespace for cert-manager
kubectl create namespace cert-manager

# Label the cert-manager namespace to disable resource validation
kubectl label namespace cert-manager certmanager.k8s.io/disable-validation=true

# Add the Jetstack Helm repository
helm repo add jetstack https://charts.jetstack.io

# Update your local Helm chart repository cache
helm repo update

# Install the cert-manager Helm chart
helm install \
  --name cert-manager \
  --namespace cert-manager \
  --version v0.10.0 \
  jetstack/cert-manager


sleep 5

# Create cluster-issuer
kubectl create -f cm-issuer.yaml
