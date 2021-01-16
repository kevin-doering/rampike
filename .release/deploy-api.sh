#!/bin/bash

function get_env {
  if [ -f ~/release/.env ]; then
    . ~/release/.env
  fi
}

function pull_manifests {
    cd ~/apx/manifests/$APP_NAME
  git pull
}

function clone_manifests {
  mkdir -p ~/apx/manifests
  cd ~/apx/manifests
  git clone $MANIFEST_REPOSITORY
}

function commit_version {
  cd ~/apx/manifests/$APP_NAME/kustomization
  kustomize edit set image $DOCKER_NAMESPACE/$APP_NAME=$DOCKER_NAMESPACE/$APP_NAME:$VERSION
  git add kustomization.yaml
  git commit -m "[ci] update image version to ${VERSION}"
  git push
}

get_env

if [ -f ~/apx/manifests/$APP_NAME/kustomization/kustomization.yaml ]; then
  pull_manifests
  commit_version
else
  remote_branch_exists=$(git ls-remote --heads $MANIFEST_REPOSITORY main)
  if [[ -z ${remote_branch_exists} ]]; then
    # TODO: register manifest repository (flux create source)
    echo "no remote origin: ${MANIFEST_REPOSITORY} with branch main"
  else
    clone_manifests
    commit_version
  fi
fi


