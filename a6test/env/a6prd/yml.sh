#!/usr/bin/env bash

set -e
set -x

source config.sh

mkdir -p ./tmp

cat k8s.yml | \
sed "s/{{ALB_IP}}/${ALB_IP}/g" | \
sed "s/{{GIT_HOST}}/${GIT_HOST}/g" | \
sed "s/{{REGISTRY}}/${REGISTRY}/g" | \
sed "s/{{REGION}}/${REGION}/g" | \
sed "s/{{NGINX}}/${NGINX}/g" | \
sed "s/{{NODE_IPS}}/${NODE_IPS}/g" | \
sed "s/{{SECOND_NAME_NODE_ADDR}}/${SECOND_NAME_NODE_ADDR}/g" | \
sed "s/{{HIVE_MYSQL_ADDR}}/${HIVE_MYSQL_ADDR}/g" | \
sed "s/{{NAME_NODE_ADDR}}/${NAME_NODE_ADDR}/g"  \
> tmp/k8s.yml

echo "use k8s-tmp.yaml to deploy the app"



