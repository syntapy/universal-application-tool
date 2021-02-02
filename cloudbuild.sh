#!/bin/bash

REGION=us-west-1
DB_NAME=postgres
APP_NAME=uat

# I had AWS_ACCOUNT_ID as an env variable from .bashrc
# Couldn't figure out how to isolate it from dictionary in bash
# in awscli result :[

# Authenticate
aws ecr get-login-password --region ${REGION} | docker login --username AWS --password-stdin ${AWS_ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com

DB_TAG=${AWS_ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com/$DB_NAME
APP_TAG=${AWS_ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com/$APP_NAME

# DB push
docker pull postgres:12.5
docker tag postgres $DB_TAG
docker push $DB_TAG

# UAT push
docker build --tag $APP_TAG --file docker/Dockerfile_uat .
docker push $APP_TAG
