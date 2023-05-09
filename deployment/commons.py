from aws_lambda_powertools.event_handler import APIGatewayRestResolver
from aws_lambda_powertools import Logger
import boto3
import os

app = APIGatewayRestResolver()
logger = Logger()

# Get the service resource
sqs = boto3.resource('sqs')
dynamodb = boto3.resource('dynamodb')

DEPLOYMENT_REQUEST_QUEUE_NAME = os.environ['DEPLOYMENT_REQUEST_QUEUE_NAME']
ENVIRONMENT = os.environ['ENVIRONMENT']
IDENTIFIER = "sail-tech"

BLUEPRINT_CONFIG_TBL = dynamodb.Table(f"{IDENTIFIER}-{ENVIRONMENT}-DeploymentTemplateConfigs")
CLIENT_TEMPLATE_CONFIG_TBL = dynamodb.Table(f"{IDENTIFIER}-{ENVIRONMENT}-ClientDeploymentTemplateConfigs")
DEPLOYMENT_HISTORY_TBL = dynamodb.Table(f"{IDENTIFIER}-{ENVIRONMENT}-DeploymentHistory")
