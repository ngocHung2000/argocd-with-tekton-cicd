# Step-by-step guide to deploying CICD with Tekton Pipeline

I. Architecture CI/CD

![Architecture](images/architecture.png)
1. Prerequisites
2. Build Infra with Terraform
```
cd ./02-infra-with-terraform
terraform init
terraform apply --auto-approve
```
![Output Terraform](images/terraform_out.png)
3. Remote to Server configure with Public IP and public key
![alt text](images/remote_server.png)

```
mkdir -p /setup
cd ./setup/
git clone https://github.com/ngocHung2000/argocd-with-tekton-cicd
cd ./argocd-with-tekton-cicd
alias k='microk8s kubectl'
alias kubectl='microk8s kubectl'
kubectl get all
```
![alt text](images/clone_git_repo.png)

- Access to resources
```
k get svc -A | grep NodePort
```
![alt text](images/show_node_port_access.png)

4. Access to Dashboard
- Tekton Dashboard
You can to access with dashboard to
```
http://3.80.36.168:31476/
```
![alt text](images/tekton_dashboard.png)
- SonarQube Dashboard
```
http://3.80.36.168:9000/
```
- Default user/passwd of SonarQube is admin/admin
![alt text](images/sonarqube_login.png)
Change Passwd
![alt text](images/chang_passwd_sonar.png)
Dashboard
![alt text](images/dasboard_sonar.png)
- ArgoCD Dashboard
Make passwd of argocd user admin u can to run command here:
```
k get secret -n argocd argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d; echo
```
![alt text](images/argocd_login.png)
Change Passwd argocd: User Info -> Update Password -> Save
![alt text](images/update_pass_argocd.png)
- Kubernetes Dashboard
Get token login dashboard
```
k get secret -n kube-system microk8s-dashboard-token -o jsonpath="{.data.token}" | base64 -d;echo
# access to dashboard
https://3.80.36.168:31851/
```
![alt text](images/k8s_dashboard_token.png)

![alt text](images/dash_board.png)

# Go back to Remote server tab
```
cd /setup/argocd-with-tekton-cicd/04-tekton-cicd
```
- Setup Storage Class and PV/PVC
```
k apply -f persistent-volumes/
k get sc
k get pvc
```
![alt text](images/pvc_sc.png)
- Setup Secret Credentials
```
ssh-keygen -t rsa -C "tongochung1809@gmail.com"
```
![alt text](images/ssh_github.png)
1. Setup for github
Setting -> SSH and GPG keys -> New SSH key -> Copy Public Key and Paste to Github -> Add SSH key
![alt text](images/public_key_ssh.png)
Next Step you can to setup secret pull repo with tekton in right here

```
export PRIVATE_KEY_GITHUB=`cat /root/.ssh/id_rsa | base64`
echo $PRIVATE_KEY_GITHUB | tr -d ' '
```
![alt text](images/private_ssh.png)
secret argocd
![alt text](images/secret_argo.png)
setup dockerhub
acces to hub.docker.com and login to your account -> My Account -> Security -> New Access Token
![alt text](images/docker_token.png)
![alt text](images/docker_token_copy.png)
![alt text](images/secret_registry.png)
Setup Sonarqube
Click Manual -> Input -> Setup -> Locally
![alt text](images/sonar_project.png)
![alt text](images/sonarqube.png)
Next Step Ucan to setup token login with secret on kubernetes
![alt text](images/edit_secret_sonar.png)
![alt text](images/sonar_token_secret.png)

```
vi ./pipeline-run/pr-cicd-example-nodejs-app.yaml
```
![alt text](images/pipelinerun.png)
Next step
1. Apply secret
```
k apply -f ./secrets/
k get secret -n default
k get secret -n argocd
```
![alt text](images/apply_secret.png)
2. Apply task
```
k apply -f ./task/
k get task -A
```
![alt text](images/apply_task.png)
3. Apply Pipeline
```
k apply -f pipeline
k get pipeline -A
```
![alt text](images/apply_pipeline.png)
4. Apply Argocd
```
k apply -f ./argocd/
k get application -A
```
![alt text](images/apply_application.png)
You can to see application on dashboard of argocd
![alt text](images/argocd_ui_application.png)
![alt text](images/app_argo.png)
5. Apply PipelineRun
```

```
![alt text](images/apply_pipeline_run.png)
![alt text](images/pipelinerun_ui_tekton.png)
sonarqube scan
![alt text](images/sonarqube_scan.png)
![alt text](images/pipeline_run_success.png)
argo sync
![alt text](images/argocd_syc.png)
access my app
![alt text](images/access_my_app.png)
prometheus_deploy
![alt text](images/prometheus_deploy.png)
![alt text](images/prometheus_show.png)
![alt text](images/prometheus_nodePort.png)
deploy grafana with helm
```
kubectl patch svc -n prometheus stable-kube-prometheus-sta-prometheus -p '{"spec": {"type": "NodePort"}}'
kubectl patch svc -n prometheus stable-grafana -p '{"spec": {"type": "NodePort"}}'
```
![alt text](images/nodePort_grafana.png)
grafana ui
```
kubectl get secret -n prometheus stable-grafana -o jsonpath="{.data.admin-password}" | base64 --decode; echo
```
![alt text](images/grafana.png)
Import Dashboard 15760
![alt text](<images/import Kubernetes.png>)
![alt text](images/k8s_dash.png)
Import 
![alt text](image.png)

![alt text](images/mem.png)
![alt text](images/dash_mem.png)
![alt text](images/dash_mem_result.png)

Deploy ELK with Helm chart
```
helm repo add elastic https://helm.elastic.co
```