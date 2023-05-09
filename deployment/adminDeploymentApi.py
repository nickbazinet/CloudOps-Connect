from commons import app
import commons
import string
import random


def id_generator(size=8, chars=string.ascii_uppercase + string.digits):
    return ''.join(random.choice(chars) for _ in range(size))


def create_deployment_blueprint():
    blueprint_name = app.current_event.json_body['name']
    blueprint_path = app.current_event.json_body['path']
    blueprint_variables = app.current_event.json_body['variables']
    blueprint_uuid = id_generator()
    tbl_response = commons.BLUEPRINT_CONFIG_TBL.put_item(
        Item={
            "uuid": blueprint_uuid,
            "name": blueprint_name,
            "path": blueprint_path,
            "variables": blueprint_variables
        }
    )

    response = {
        "uuid": blueprint_uuid,
        "name": blueprint_name,
        "path": blueprint_path,
        "variables": blueprint_variables
    }

    return response


def update_deployment_blueprint():
    blueprint_id = app.current_event.query_string_parameters['id']
    blueprint_name = app.current_event.json_body['name']
    blueprint_path = app.current_event.json_body['path']
    blueprint_variables = app.current_event.json_body['variables']

    tbl_response = commons.BLUEPRINT_CONFIG_TBL.update_item(
        Key={
            "uuid": blueprint_id,
            "name": blueprint_name
        },
        UpdateExpression="SET #path = :path, #variables = :variables",
        ExpressionAttributeNames={
            '#path': 'path',
            '#variables': 'variables'
        },
        ExpressionAttributeValues={
            ':path': blueprint_path,
            ':variables': blueprint_variables
        },
        ReturnValues="UPDATED_NEW"
    )

    response = {
        "uuid": blueprint_id,
        "name": blueprint_name,
        "path": blueprint_path,
        "variables": blueprint_variables
    }

    return tbl_response
