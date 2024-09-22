#!/usr/bin/env bash

if [ ! -f .env ]; then
    echo "Иди найди где-нибудь енвы для этого окружения"
else
    source .env

    export TF_VAR_s3_access_key
    export TF_VAR_s3_secret_key

    export YC_TOKEN=$(yc iam create-token)
    export YC_CLOUD_ID=$(yc config get cloud-id)
    export YC_FOLDER_ID=$(yc config get folder-id)
fi
