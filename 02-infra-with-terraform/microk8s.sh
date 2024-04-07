#!/bin/bash
# Install Microk8s
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl.sha256"
echo "$(cat kubectl.sha256)  kubectl" | sha256sum --check
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

chmod +x kubectl
mkdir -p ~/.local/bin
mv ./kubectl ~/.local/bin/kubectl
kubectl version --client --output=yaml

sudo snap install microk8s --classic --channel=1.27
sudo usermod -a -G microk8s $USER
sudo mkdir -p ~/.kube
sudo chown -f -R $USER ~/.kube

snap start microk8s

su - $USER
microk8s status --wait-ready

microk8s enable dashboard
microk8s enable dns
microk8s enable istio
microk8s enable hostpath-storage
# Setup Tekton
microk8s kubectl create ns tekton-pipelines
microk8s kubectl apply --filename https://storage.googleapis.com/tekton-releases/pipeline/latest/release.yaml
microk8s kubectl apply --filename https://storage.googleapis.com/tekton-releases/triggers/latest/interceptors.yaml
microk8s kubectl apply --filename https://storage.googleapis.com/tekton-releases/dashboard/latest/release.yaml
microk8s kubectl apply --filename https://storage.googleapis.com/tekton-releases/triggers/latest/release.yaml

# Install ArgoCD CLI
curl -sSL -o argocd-linux-amd64 https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64
sudo install -m 555 argocd-linux-amd64 /usr/local/bin/argocd
rm argocd-linux-amd64

# Setup Argocd
microk8s kubectl create namespace argocd
microk8s kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Install Helm 
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh
rm -rf ./get_helm.sh
helm version

# Add Docker's official GPG key:
sudo apt-get update
sudo apt-get install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Docker Installation
# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update -y

sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y

chmod 777 /var/run/docker.sock

# Start Sonarqube with Docker
docker run -d --name sonar -p 9000:9000 sonarqube:lts-community

microk8s kubectl patch svc -n argocd argocd-server -p '{"spec": {"type": "NodePort"}}'
microk8s kubectl patch svc -n tekton-pipelines tekton-dashboard -p '{"spec": {"type": "NodePort"}}'
microk8s kubectl patch svc -n kube-system kubernetes-dashboard -p '{"spec": {"type": "NodePort"}}'


# helm repo add prometheus-community https://prometheus-community.github.io/helm-charts

# kubectl create ns prometheus

# helm install stable prometheus-community/kube-prometheus-stack -n prometheus

# kubectl get po -n prometheus

# # Change type svc is LoadBalancer and port 8080 -> 9090
# kubectl edit svc stable-kube-prometheus-sta-prometheus -n prometheus
# # Change type svc is LoadBalancer
# kubectl edit svc stable-grafana -n prometheus
# # Show passwd grafana with user is admin
# kubectl get secret -n prometheus stable-grafana -o jsonpath="{.data.admin-password}" | base64 --decode; echo

# Config Grafana and Prometheus
# Import with 15760
# Import with 12740