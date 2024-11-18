# Supprimer toutes les releases
releases=$(helm ls --all --short | grep "^chartsgouv")
for release in $releases; do
    helm delete "$release"
done

pods=$(kubectl get pods -o name | grep "^pod/chartsgouv" | cut -d'/' -f2)
for pod in $pods; do
    kubectl delete pods "$pod"
done

deployments=$(kubectl get deployments -o name | grep "^deployment.apps/chartsgouv" | cut -d'/' -f2)
for deployment in $deployments; do
    kubectl delete deployment "$deployment"
done

# Supprimer tous les ingress commençant par "reuniokit"
ingresses=$(kubectl get ing -o name | grep "^ingress.networking.k8s.io/chartsgouv" | cut -d'/' -f2)
for ingress in $ingresses; do
    kubectl delete ingress "$ingress"
done

services=$(kubectl get services -o name | grep "^service/chartsgouv" | cut -d'/' -f2)
for service in $services; do
    kubectl delete service "$service"
done


echo "Everything about chartsgouv has been deleted"

helm repo add superset http://apache.github.io/superset/
helm repo update superset
helm install chartsgouv-4184 superset/superset -f values.yaml
