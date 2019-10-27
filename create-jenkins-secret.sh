#!/bin/bash


kubeseal --fetch-cert \
--controller-namespace=capstone-adm \
--controller-name=sealed-secrets \
> pub-cert.pem

kubectl create secret generic regcred \
	--namespace capstone-build  \
	--from-file=.dockerconfigjson=/home/seifl/.docker/config.json \
	--type=kubernetes.io/dockerconfigjson \
	--dry-run \
	-o json > reg-cred.json

kubeseal --format=yaml --cert=pub-cert.pem < reg-cred.json > releases/capstone-build/reg-cred.yaml

rm reg-cred.json
cat releases/capstone-build/reg-cred.yaml

git add releases/capstone-build/reg-cred.yaml

kubectl -n capstone-build create secret generic jenkins-secret \
        --from-literal=GITHUB_USER=$1 \
        --from-literal=GITHUB_PW=$2 \
        --from-literal=GITHUB_TOKEN=$3 \
        --from-literal=DOCKERHUB_USER=$4 \
        --from-literal=DOCKERHUB_PW=$5 \
        --dry-run \
        -o json > jenkins-secret.json

kubeseal --format=yaml \
         --cert=pub-cert.pem \
         < jenkins-secret.json \
         > releases/capstone-build/jenkins-secret.yaml

rm jenkins-secret.json

git add releases/capstone-build/jenkins-secret.yaml
git commit -m "Add Jenkins password secret"
git push

