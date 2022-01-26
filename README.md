# Howto

* Clone the repo: git clone https://github.com/vpletea/setup.git && cd setup
* Install ansible: make ansible
* Configure the computer: make setup

# K3d cluster with docker local registry ( no traefik )

    kc
    docker container run -d --name registry.localhost --restart always -p 5000:5000 registry:2
    docker network connect k3d-k3s-default registry.localhost

* dont forget to add 127.0.0.1 registry.localhost to your /etc/hosts file
* more info at https://k3d.io/usage/guides/registries/

# Registries yaml file

    mirrors:
    "registry.localhost:5000":
        endpoint:
        - http://registry.localhost:5000

# Install nginx-ingress

    helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
    helm repo update
    helm install ingress-nginx ingress-nginx/ingress-nginx

# Test

    docker pull nginx:latest
    docker tag nginx:latest registry.localhost:5000/nginx:latest
    docker push registry.localhost:5000/nginx:latest
    cat <<EOF | kubectl apply -f -
            apiVersion: apps/v1
            kind: Deployment
            metadata:
            name: nginx-test-registry
            labels:
                app: nginx-test-registry
            spec:
            replicas: 1
            selector:
                matchLabels:
                app: nginx-test-registry
            template:
                metadata:
                labels:
                    app: nginx-test-registry
                spec:
                containers:
                - name: nginx-test-registry
                    image: registry.localhost:5000/nginx:latest
                    ports:
                    - containerPort: 80
            EOF
    kubectl get pods -l "app=nginx-test-registry"

# Work folder config

    git config user.name "Firstname Lastname"
    git config user.email "firstname.lastname@example.com"

# Github related settings

    chmod 400 ~/.ssh/id_rsa
    eval $(ssh-agent -s)
    ssh-add ~/.ssh/id_rsa



