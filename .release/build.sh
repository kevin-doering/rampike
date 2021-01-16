#!/bin/bash

function get_env {
  if [ -f ~/release-$APP_NAME/.env ]; then
    . ~/release-$APP_NAME/.env
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
  docker login -u $WORKDIR_NAMESPACE -p $DOCKER_PASSWORD
  docker build --cache-from $WORKDIR_NAMESPACE/$APP_NAME:latest  -t $WORKDIR_NAMESPACE/$APP_NAME:latest . -f .docker/$ARCH_TARGET.Dockerfile --build-arg APP_NAME=$APP_NAME --build-arg CONTAINER_PORT=$CONTAINER_PORT --build-arg RELEASE=$VERSION --build-arg BUILDKIT_INLINE_CACHE=1
  docker tag $WORKDIR_NAMESPACE/$APP_NAME:latest $WORKDIR_NAMESPACE/$APP_NAME:$VERSION
  docker push $WORKDIR_NAMESPACE/$APP_NAME:latest
  docker push $WORKDIR_NAMESPACE/$APP_NAME:$VERSION
}

get_env

if [ -f ~/apx/projects/$CI_PROJECT_NAME/package.json ]; then
  pull_workspace
  build_image
else
  remote_branch_exists=$(git ls-remote --heads $WORKSPACE_REPOSITORY main)
  if [[ -z ${remote_branch_exists} ]]; then
    echo "no remote origin workspace: ${WORKSPACE_REPOSITORY} with branch main"
  else
    clone_workspace
    build_image
  fi
fi

