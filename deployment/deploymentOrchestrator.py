import boto3
import os
import json
from DeploymentRequest import DeploymentRequest

# Get the service resource
sqs = boto3.resource('sqs')
dynamodb = boto3.resource('dynamodb')

DEPLOYMENT_REQUEST_QUEUE_NAME = os.environ['DEPLOYMENT_REQUEST_QUEUE_NAME']
ENVIRONMENT = os.environ['ENVIRONMENT']
IDENTIFIER = "sail-tech"

CLIENT_TEMPLATE_CONFIG_TBL = dynamodb.Table(f"{IDENTIFIER}-{ENVIRONMENT}-ClientDeploymentTemplateConfigs")
DEPLOYMENT_HISTORY_TBL = dynamodb.Table(f"{IDENTIFIER}-{ENVIRONMENT}-DeploymentHistory")


def lambda_handler(event, context):
    """
    Lambda responsible to orchestrate the deployment of a new Services.
    It is responsible to validate the client's request, making sure all permission are adequate and preparing the
    metadata for the deployment (status, auditing, request path, project, etc).
    :param event:
    :param context:
    :return:
    """
    client_id = event['queryStringParameters']['clientId']
    template_id = event['queryStringParameters']['templateId']

    print(f"Query String Parameters: {event['queryStringParameters']}")

    client_template_config_item = CLIENT_TEMPLATE_CONFIG_TBL.get_item(
        Key={
            "client_template_id": f"{client_id}_{template_id}"
        }
    )

    if 'Item' in client_template_config_item:
        deployment_path = client_template_config_item['Item']['deployment_path']
        deployment_vars = client_template_config_item['Item']['variables']
    else:
        raise Exception("ClientDeploymentTemplateConfigs Item not found")

    DEPLOYMENT_HISTORY_TBL.put_item(
        Item={
            "client_template_id": f"{client_id}_{template_id}",
            "status": "PENDING",
            "variable": deployment_vars
        }
    )

    deployment_request_queue = sqs.get_queue_by_name(QueueName=DEPLOYMENT_REQUEST_QUEUE_NAME)

    deployment_request = DeploymentRequest(client_id, template_id, deployment_vars, deployment_path)

    json_requests = json.dumps(deployment_request, indent=4, default=vars)
    print(f"Sending {json_requests}.")
    sqs_response = deployment_request_queue.send_message(
        MessageBody=json_requests,
        MessageGroupId=f'{deployment_request.client_id}-DeploymentRequest')

    lambda_response = {
        "isBase64Encoded": "true",
        "statusCode": 200,
        "headers": {
            "Content-Type": "application/json",
            "Access-Control-Allow-Origin": "*"
        },
        "body": json_requests
    }

    return lambda_response
