#!/bin/sh

# Configure Your AWS credentials
aws configure set aws_access_key_id <your_aws_access_key_id>
aws configure set aws_secret_access_key <your_aws_secret_access_key_id>
aws configure set region <your_aws_region>

# Deploying PHP runtime as layer for Lambda function.
layerArn=$(aws lambda publish-layer-version \
    --layer-name runtime \
    --zip-file fileb://runtime.zip | jq -r '.LayerVersionArn')

# Deploying Lambda function using created layer.
aws lambda create-function \
      --function-name serverless-php-todo \
      --handler index.handler \
      --zip-file fileb://src.zip \
      --runtime provided.al2 \
      --timeout 10 \
      --role <your_aws_role_arn> \
      --layers $layerArn \
      --environment "Variables={}"    # You can specify env variables here if any , i.e --environment "Variables={DATABASE_HOST=localhost}"








