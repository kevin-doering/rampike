#!/bin/bash

function get_env {
  if [ -f ~/release/.env ]; then
    . ~/release/.env
  fi
}

function pull_workspace {
  cd ~/apx/projects/$CI_PROJECT_NAME
  git pull
}

function clone_workspace {
  mkdir -p ~/apx/projects
  cd ~/apx/projects
  git clone $WORKSPACE_REPOSITORY
  cd ./$CI_PROJECT_NAME
}

function build_image {
  local DOCKER_BUILDKIT=1
  docker login -u $DOCKER_NAMESPACE -p $DOCKER_PASSWORD
  docker build --cache-from $DOCKER_NAMESPACE/$APP_NAME:latest  -t $DOCKER_NAMESPACE/$APP_NAME:latest . -f .docker/api-aarch64.Dockerfile --build-arg APP_NAME=$APP_NAME --build-arg RELEASE=$VERSION --build-arg BUILDKIT_INLINE_CACHE=1
  docker tag $DOCKER_NAMESPACE/$APP_NAME:latest $DOCKER_NAMESPACE/$APP_NAME:$VERSION
  docker push $DOCKER_NAMESPACE/$APP_NAME:latest
  docker push $DOCKER_NAMESPACE/$APP_NAME:$VERSION
}

get_env

if [ -f ~/apx/projects/$CI_PROJECT_NAME/package.json ]; then
  pull_workspace
  build_image
else
  remote_branch_exists=$(git ls-remote --heads $WORKSPACE_REPOSITORY main)
  if [[ -z ${remote_branch_exists} ]]; then
    echo "no remote origin: ${WORKSPACE_REPOSITORY} with branch main"
  else
    clone_workspace
    build_image
  fi
fi

