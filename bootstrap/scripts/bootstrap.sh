#!/bin/bash

set -e

# https://checkpoint-api.hashicorp.com/v1/check/terraform
TF_VERSION="0.12.24"

yum -y install unzip

if [ ! -e /usr/local/bin/terraform ]; then
  curl -s -O https://releases.hashicorp.com/terraform/${TF_VERSION}/terraform_${TF_VERSION}_linux_amd64.zip
  unzip terraform_${TF_VERSION}_linux_amd64.zip -d /usr/local/bin/
fi

# cleanup
rm terraform_${TF_VERSION}_linux_amd64.zip