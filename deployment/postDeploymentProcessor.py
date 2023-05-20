import json
import commons


def lambda_handler(event, context):
    """
    Lambda responsible for handling the post deployment logic. Its goal is to update the metadata related
    to the previous deployment.
    :param event:
    :param context:
    :return:
    """

    sns_payload = event['Records'][0]['Sns']
    post_event_payload = json.loads(sns_payload['Message'])

    commons.DEPLOYMENT_HISTORY_TBL.update_item(
        Key={
            "client_template_id": post_event_payload['client_template_id']
        },
        UpdateExpression="SET #status = :status",
        ExpressionAttributeNames={
            '#status': 'status'
        },
        ExpressionAttributeValues={
            ':status': "COMPLETED",
        },
        ReturnValues="UPDATED_NEW"
    )

    client_id = post_event_payload['client_template_id'].split('_')[0]
    template_id = post_event_payload['client_template_id'].split('_')[1]
    print(f"Successfully completed deployment for client #{client_id} on template #{template_id}.")
