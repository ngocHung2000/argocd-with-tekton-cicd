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