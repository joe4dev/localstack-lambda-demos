# Deploy via SAM
samlocal deploy --template template.yaml --stack-name localstack --resolve-s3 --no-confirm-changeset

### Hot Reloading

# https://docs.localstack.cloud/user-guide/tools/lambda-tools/hot-reloading/

# CodeUri:
#   Bucket: hot-reload
#   Key: /Users/joe/Projects/LocalStack/localstack-lambda-demos/localstack-lambda/src/

### Remote Debugging

# https://docs.localstack.cloud/user-guide/tools/lambda-tools/debugging/

# import debugpy
# debugpy.listen(("0.0.0.0", 19891))
# debugpy.wait_for_client()  # blocks execution until client is attached

# Layers:
#   - arn:aws:lambda:us-east-1:879723642032:layer:debugpy-layer:1

### Transparent Endpoint Injection (Pro)

# https://docs.localstack.cloud/user-guide/tools/transparent-endpoint-injection/

# import boto3
# client = boto3.client('lambda')
# response = client.get_account_settings()

### Concurrency

# NOTE: remove Docker port mapping due to current single mapping limitation

# Publish function
awslocal lambda publish-version --function-name localstack-lambda

# Create provisioned concurrency
awslocal lambda put-provisioned-concurrency-config --function-name localstack-lambda --qualifier 1 --provisioned-concurrent-executions 4

# Delete provisioned concurrency config
awslocal lambda delete-provisioned-concurrency-config --function-name localstack-lambda --qualifier 1

### Preparations for sharing a public AWS layer

# Install Python package locally
mkdir -p debugpy_layer/python
cd debugpy_layer/python
pip install debugpy -t .

# Package layer
cd ..
zip -r debugpy_layer.zip .

# Create layer
awslocal lambda publish-layer-version --layer-name debugpy-layer \
    --description "Packages the Python debugpy pip dependency" \
    --license-info "MIT" \
    --zip-file fileb://debugpy_layer.zip \
    --compatible-runtimes python3.8 python3.9 python3.10 \
    --compatible-architectures "arm64" "x86_64"

# local ARN: arn:aws:lambda:us-east-1:000000000000:layer:debugpy-layer:1
# shared ARN: arn:aws:lambda:us-east-1:879723642032:layer:debugpy-layer:1

# Create permissions for shared AWS layer
# https://docs.localstack.cloud/user-guide/aws/lambda/#referencing-lambda-layers-from-aws
aws lambda add-layer-version-permission \
    --layer-name debugpy-layer \
    --version-number 1 \
    --statement-id layerAccessFromLocalStack \
    --principal 886468871268 \
    --action lambda:GetLayerVersion
