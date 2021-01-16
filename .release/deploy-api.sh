#!/bin/bash

if [ -f ~/release/.env ]; then
    . ~/release/.env
fi

if [ -f ~/apx/manifests/$APP_NAME/kustomization/kustomization.yaml ]; then
  cd ~/apx/manifests/$APP_NAME
  git pull
else
  mkdir -p ~/apx/manifests
  cd ~/apx/manifests
  git clone $MANIFEST_REPOSITORY
fi

cd ~/apx/manifests/$APP_NAME/kustomization
kustomize edit set image $DOCKER_USER/$APP_NAME=$DOCKER_USER/$APP_NAME:$VERSION
git add kustomization.yaml
git commit -m "[ci] update image version"
git push


