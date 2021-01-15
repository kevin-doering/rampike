#!/bin/bash

if [ -f ~/release/.env ]; then
    . ~/release/.env
fi

if [ -f ~/apx/manifests/$CI_PROJECT_NAME/package.json ]; then
  cd ~/apx/manifests/$CI_PROJECT_NAME
  git pull
else
  mkdir -p ~/apx/manifests
  cd ~/apx/manifests
  git clone $MANIFEST_REPOSITORY
  cd ./$CI_PROJECT_NAME
fi
