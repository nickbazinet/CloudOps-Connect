import os
import requests
import json
import boto3
from InvalidGitlabResponseException import InvalidGitlabResponseException

# Get the service resource
ssm_client = boto3.client('ssm')
GITLAB_TOKEN_PARAM = ssm_client.get_parameter(Name=os.environ['gitlab_token_ssm_path'], WithDecryption=False)
GITLAB_TOKEN = GITLAB_TOKEN_PARAM['Parameter']['Value']


def lambda_handler(event, context):
    """
    Lambda responsible for calling the Deployment-Hub with the proper parameter based on a message received in SQS.
    :param event:
    :param context:
    :return:
    """

    event_body = json.loads(event['Records'][0]['body'])
    print(f"Events data: {event_body}")

    request_vars = "&variables[VARS]="
    for k, v in event_body['terraform_variables'].items():
        request_vars += f"{k}:{v},"
    request_vars = request_vars.removesuffix(",")

    client_template_id = f"{event_body['client_id']}_{event_body['template_id']}"
    response = requests.post(f"https://gitlab.com/api/v4/projects/45580398/ref/master/trigger/pipeline"
                             f"?token={GITLAB_TOKEN}{request_vars}"
                             f"&variables[TERRAFORM_PLAN_SOURCE]={event_body['terraform_plan_path']}"
                             f"&variables[CLIENT_TEMPLATE_ID]={client_template_id}")

    if not response.ok:
        raise InvalidGitlabResponseException(response)
    else:
        print("Successfully started Deployment-Hub pipeline.")
