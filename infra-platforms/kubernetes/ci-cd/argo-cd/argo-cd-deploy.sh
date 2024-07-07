helm repo add argo https://argoproj.github.io/argo-helm
helm repo update

kubectl create namespace argocd

helm install argocd -n argocd argo/argo-cd

#Get the administrator password (or just copy the command from the Helm output):
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d

kubectl port-forward service/argocd-server -n argocd 8080:443 --address="0.0.0.0" &

# Open the browser and navigate to 192.168.2.30:8080. Accept the security risk. Enter the username: admin and paste
# the password from the above output.


kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/master/deploy/static/provider/kind/deploy.yaml