from commons import app
import commons


def create_client_deployment():
    client_id = app.current_event.json_body['clientId']
    template_id = app.current_event.json_body['templateId']
    deployment_path = app.current_event.json_body['deploymentPath']
    deployment_variables = app.current_event.json_body['variables']

    tbl_response = commons.CLIENT_TEMPLATE_CONFIG_TBL.put_item(
        Item={
            "client_template_id": f"{client_id}_{template_id}",
            "deployment_path": deployment_path,
            "variable": deployment_variables
        }
    )

    return tbl_response['Attributes']


def update_client_deployment():
    client_id = app.current_event.json_body['clientId']
    template_id = app.current_event.json_body['templateId']
    deployment_path = app.current_event.json_body['deploymentPath']
    deployment_variables = app.current_event.json_body['variables']

    tbl_response = commons.CLIENT_TEMPLATE_CONFIG_TBL.update_item(
        Key={
            "client_template_id": f"{client_id}_{template_id}"
        },
        Item={
            "deployment_path": deployment_path,
            "variable": deployment_variables
        }
    )

    return tbl_response['Attributes']
