#!/bin/bash

if [ -f ~/release/.env ]; then
    . ~/release/.env
fi

if [ -f ~/apx/projects/$CI_PROJECT_NAME/package.json ]; then
  cd ~/apx/projects/$CI_PROJECT_NAME
  git pull
else
  mkdir -p ~/apx/projects
  cd ~/apx/projects
  git clone $PROJECT_REPOSITORY
  cd ./$CI_PROJECT_NAME
fi

docker login -u $DOCKER_USER -p $DOCKER_PASSWORD
docker build -t $DOCKER_USER/$APP_NAME:$VERSION . -f .docker/api-aarch64.Dockerfile --build-arg APP_NAME=$APP_NAME
docker push $DOCKER_USER/$APP_NAME:$VERSION
