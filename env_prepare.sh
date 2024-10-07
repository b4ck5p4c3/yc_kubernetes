#!/usr/bin/env bash
export AWS_ACCESS_KEY_ID=$(yc lockbox payload get --name terraform_s3_keys --format json | jq '.entries[] | select(.key == "AWS_ACCESS_KEY_ID") | .text_value')
export AWS_SECRET_ACCESS_KEY=$(yc lockbox payload get --name terraform_s3_keys --format json | jq '.entries[] | select(.key == "AWS_SECRET_ACCESS_KEY") | .text_value')

export YC_TOKEN=$(yc iam create-token)
export YC_CLOUD_ID=$(yc config get cloud-id)
export YC_FOLDER_ID=$(yc config get folder-id)
