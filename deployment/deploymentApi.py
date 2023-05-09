import json
from deploymentRequest import DeploymentRequest
from commons import app
from commons import logger
import commons


def deploy():
    """
    Lambda responsible to orchestrate the deployment of a new Services.
    It is responsible to validate the client's request, making sure all permission are adequate and preparing the
    metadata for the deployment (status, auditing, request path, project, etc).
    :return:
    """
    client_id = app.current_event.query_string_parameters['clientId']
    template_id = app.current_event.query_string_parameters['templateId']

    logger.info(f"Query String Parameters: {app.current_event.query_string_parameters}")

    client_template_config_item = commons.CLIENT_TEMPLATE_CONFIG_TBL.get_item(
        Key={
            "client_template_id": f"{client_id}_{template_id}"
        }
    )

    if 'Item' in client_template_config_item:
        deployment_path = client_template_config_item['Item']['deployment_path']
        deployment_vars = client_template_config_item['Item']['variables']
    else:
        raise Exception("ClientDeploymentTemplateConfigs Item not found")

    commons.DEPLOYMENT_HISTORY_TBL.put_item(
        Item={
            "client_template_id": f"{client_id}_{template_id}",
            "status": "PENDING",
            "variable": deployment_vars
        }
    )

    deployment_request_queue = commons.sqs.get_queue_by_name(QueueName=commons.DEPLOYMENT_REQUEST_QUEUE_NAME)

    deployment_request = DeploymentRequest(client_id, template_id, deployment_vars, deployment_path)

    json_requests = json.dumps(deployment_request, indent=4, default=vars)
    logger.info(f"Sending {json_requests}.")
    deployment_request_queue.send_message(
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

    return json_requests
