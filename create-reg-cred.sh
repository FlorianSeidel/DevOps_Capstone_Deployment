#/bin/bash.sh
#Run this to create the docker login credentials secret
#This is needed so that kubernetes can pull the build slave images for jenkins
#Secret is encrypted using bitnami sealed-secrets.
#Install sealed secrets first, using helm chart or flux, then get the 
#public certificate. 

kubeseal --fetch-cert \
--controller-namespace=capstone-adm \
--controller-name=sealed-secrets \
> pub-cert.pem

kubectl create secret generic regcred \
	--namespace capstone-dev  \
	--from-file=.dockerconfigjson=/home/seifl/.docker/config.json \
	--type=kubernetes.io/dockerconfigjson \
	--dry-run \
	-o json > reg-cred.json

kubeseal --format=yaml --cert=pub-cert.pem < reg-cred.json > releases/capstone-dev/reg-cred.yaml

rm reg-cred.json
cat releases/capstone-dev/reg-cred.yaml

git add releases/capstone-dev/reg-cred.yaml

git commit -a -m "Add docker registry credentials." && git push
