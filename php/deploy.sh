#!/bin/sh

# Configure Your AWS credentials
aws configure set aws_access_key_id AKIAYJJIHLXJD3QOT6FD
aws configure set aws_secret_access_key GpXyyKI7xd6XzKM/5M+ZHi0cgm/bIzJa1ekmBDMK
aws configure set region ap-south-1

# Deploying PHP runtime as layer for Lambda function
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
      --role arn:aws:iam::569704406482:role/service-role/LambdaPhpExample \
      --layers $layerArn \
      --environment "Variables={}"    # You can specify env variables here if any , i.e --environment "Variables={DATABASE_HOST=localhost}"








