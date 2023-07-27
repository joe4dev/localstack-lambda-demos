### Getting Started
# https://docs.localstack.cloud/user-guide/aws/lambda/

# Start LocalStack
localstack start

# Check health endpoint
curl http://localhost:4566/_localstack/health -s | jq

# Create execution role
aws iam create-role --role-name lambda-role --assume-role-policy-document '{"Version": "2012-10-17","Statement": [{ "Effect": "Allow", "Principal": {"Service": "lambda.amazonaws.com"}, "Action": "sts:AssumeRole"}]}'

# Attach execution permission
aws iam attach-role-policy --role-name lambda-role --policy-arn arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole

# List Lambda functions
aws lambda list-functions --endpoint-url http://localhost:4566
awslocal lambda list-functions

# Get account settings
awslocal lambda get-account-settings

# Package Lambda function handler into ZIP file
zip function.zip index.js

# Create Lambda function
awslocal lambda create-function \
    --function-name localstack-lambda-url-example \
    --runtime nodejs18.x \
    --zip-file fileb://function.zip \
    --handler index.handler \
    --role arn:aws:iam::000000000000:role/lambda-role

# List function
awslocal lambda list-functions

# Get function
awslocal lambda get-function --function-name localstack-lambda-url-example

# Create a Function URL
awslocal lambda create-function-url-config \
    --function-name localstack-lambda-url-example \
    --auth-type NONE

# Trigger the Lambda function URL (replace <XXXXXXXX> with the generated URL id)
curl -X POST \
    'http://<XXXXXXXX>.lambda-url.us-east-1.localhost.localstack.cloud:4566/' \
    -H 'Content-Type: application/json' \
    -d '{"num1": "10", "num2": "10"}'

# Add Lambda resource policy
aws lambda add-permission --function-name localstack-lambda-url-example --action lambda:InvokeFunctionUrl --statement-id https --principal "*" --function-url-auth-type NONE --output text

# Delete function
aws lambda delete-function --function-name localstack-lambda-url-example
