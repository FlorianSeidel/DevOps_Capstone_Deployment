#!/bin/bash

kubectl -n capstone-build create secret generic \
--from-literal=GITHUB_USER=$1
--from-literal=GITHUB_PW=$2 \
--from-literal=GITHUB_TOKEN=$3 \
--from-literal=DOCKERHUB_USER=$4
--from-literal=DOCKERHUB_PW=$5 \
--dry-run \
-o json > jenkins-secret.json

kubeseal --format=yaml --cert=pub-cert.pem < jenkins-secret.json > releases/capstone-build/jenkins-secret.yaml

rm jenkins-secret.json

git add releases/capstone-build/jenkins-secret.yaml
git commit -m "Add Jenkins password secret"
git push

