#!/bin/bash

function get_env {
  if [ -f ~/release-${TYPE}/.env ]; then
    . ~/release-${TYPE}/.env
  fi
}

function pull_manifests {
  cd ~/apx/manifests/$APP_NAME
  git pull
}

function clone_manifests {
  mkdir -p ~/apx/manifests
  cd ~/apx/manifests
  git clone git@$GITHUB_DOMAIN:$GITHUB_NAMESPACE/$APP_NAME.git
}

function commit_version {
  cd ~/apx/manifests/$APP_NAME/kustomization
  kustomize edit set image $WORKDIR_NAMESPACE/$APP_NAME=$WORKDIR_NAMESPACE/$APP_NAME:$VERSION
  git add kustomization.yaml
  git commit -m "[ci] update image version to ${VERSION}"
  git push
}

function create_new_repository {
  mkdir -p ~/apx/manifests/$APP_NAME
  cd ~/apx/manifests/$APP_NAME
  git init
  gh repo create $APP_NAME --confirm --public --description=$APP_NAME
  echo "# ${APP_NAME} manifests" > README.md
  git add README.md
  git commit -m "create ${APP_NAME} manifest repository"
  git remote set-url origin git@$GITHUB_DOMAIN:$GITHUB_NAMESPACE/$APP_NAME.git
  git push --set-upstream origin main
  mkdir -p kustomization
}

function add_kustomization {
  cat <<EOF | tee ~/apx/manifests/$APP_NAME/kustomization/kustomization.yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
- deployment.yaml
- service.yaml
- ingress-route.yaml
- certificate.yaml
- hpa.yaml
images:
- name: $WORKDIR_NAMESPACE/$APP_NAME
  newName: $WORKDIR_NAMESPACE/$APP_NAME
  newTag: $VERSION
EOF
}

function add_deployment {
  cat <<EOF | tee ~/apx/manifests/$APP_NAME/kustomization/deployment.yaml
---
kind: Deployment
apiVersion: apps/v1
metadata:
  name: $APP_NAME
  namespace: $APP_NAME
  labels:
    app: $APP_NAME
spec:
  minReadySeconds: 3
  revisionHistoryLimit: 5
  progressDeadlineSeconds: 60
  strategy:
    rollingUpdate:
      maxUnavailable: 0
    type: RollingUpdate
  selector:
    matchLabels:
      app: $APP_NAME
  template:
    metadata:
      labels:
        app: $APP_NAME
    spec:
      containers:
      - name: $APP_NAME
        image: $WORKDIR_NAMESPACE/$APP_NAME:0.0.0
        imagePullPolicy: IfNotPresent
        ports:
        - name: web
          containerPort: $CONTAINER_PORT
        livenessProbe:
          httpGet:
            path: /
            port: $CONTAINER_PORT
          initialDelaySeconds: 5
          timeoutSeconds: 5
          periodSeconds: 15
        readinessProbe:
          httpGet:
            path: /
            port: $CONTAINER_PORT
          initialDelaySeconds: 5
          timeoutSeconds: 5
        resources:
          limits:
            cpu: 2000m
            memory: 512Mi
          requests:
            cpu: 100m
            memory: 64Mi
EOF
}

function add_service {
  cat <<EOF | tee ~/apx/manifests/$APP_NAME/kustomization/service.yaml
---
apiVersion: v1
kind: Service
metadata:
  name: $APP_NAME
  namespace: $APP_NAME
spec:
  selector:
    app: $APP_NAME
  ports:
  - protocol: TCP
    port: 80
    targetPort: $CONTAINER_PORT
  type: ClusterIP
EOF
}

function add_ingress_route {
  cat <<EOF | tee ~/apx/manifests/$APP_NAME/kustomization/ingress-route.yaml
---
apiVersion: traefik.containo.us/v1alpha1
kind: IngressRoute
metadata:
  name: $APP_NAME
  namespace: $APP_NAME
spec:
  entryPoints:
    - websecure
  routes:
  - match: Host(\`${APP_NAME}.rampike.de\`)
    kind: Rule
    services:
    - name: $APP_NAME
      port: 80
  tls:
    secretName: $APP_NAME-certificate
EOF
}

function add_certificate {
  cat <<EOF | tee ~/apx/manifests/$APP_NAME/kustomization/certificate.yaml
---
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: $APP_NAME
  namespace: $APP_NAME
spec:
  dnsNames:
  - $APP_NAME.rampike.de
  issuerRef:
    kind: ClusterIssuer
    name: acme-staging
  secretName: $APP_NAME-certificate
EOF
}

function add_pod_scaler {
  cat <<EOF | tee ~/apx/manifests/$APP_NAME/kustomization/hpa.yaml
---
apiVersion: autoscaling/v2beta2
kind: HorizontalPodAutoscaler
metadata:
  name: $APP_NAME
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: $APP_NAME
  minReplicas: 1
  maxReplicas: 4
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 88
EOF
}

function commit_manifests {
  cd ~/apx/manifests/$APP_NAME
  git add kustomization/
  git commit -m "add initial manifest configuration"
  git push
}

function pull_flux_state {
    cd ~/apx/flux-cd
    git pull
}

function register_in_flux {
  mkdir -p ~/apx/flux-cd/cluster/$WORKDIR_NAMESPACE/$APP_NAME

  flux create source git $APP_NAME \
    --url https://$GITHUB_DOMAIN/$GITHUB_NAMESPACE/$APP_NAME \
    --branch main \
    --interval 1m \
    --export \
    | tee ~/apx/flux-cd/cluster/$WORKDIR_NAMESPACE/$APP_NAME/source.yaml

  flux create kustomization $APP_NAME \
    --source $APP_NAME \
    --path "./kustomization" \
    --prune true \
    --validation client \
    --interval 5m \
    --export \
    | tee -a ~/apx/flux-cd/cluster/$WORKDIR_NAMESPACE/$APP_NAME/source.yaml
}

function commit_source {
  cd ~/apx/flux-cd/cluster/$WORKDIR_NAMESPACE/$APP_NAME
  git add source.yaml
  git commit -m "register manifest repository as source in flux-system"
  git push origin main
}

get_env

if [ -f ~/apx/manifests/$APP_NAME/kustomization/kustomization.yaml ]; then
  pull_manifests
  commit_version
else
  remote_branch_exists=$(git ls-remote --heads git@$GITHUB_DOMAIN:$GITHUB_NAMESPACE/$APP_NAME.git main)
  if [[ -z ${remote_branch_exists} ]]; then
    create_new_repository
    add_kustomization
    add_deployment
    add_service
    add_ingress_route
    add_certificate
    add_pod_scaler
    commit_manifests
    pull_flux_state
    register_in_flux
    commit_source
  else
    clone_manifests
    commit_version
  fi
fi


