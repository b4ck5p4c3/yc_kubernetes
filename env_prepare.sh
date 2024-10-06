#!/usr/bin/env bash

if [ ! -f .env ]; then
    echo "Иди найди где-нибудь енвы для этого окружения"
else
    source .env

    export AWS_ACCESS_KEY_ID
    export AWS_SECRET_ACCESS_KEY

    export YC_TOKEN=$(yc iam create-token)
    export YC_CLOUD_ID=$(yc config get cloud-id)
    export YC_FOLDER_ID=$(yc config get folder-id)
fi
