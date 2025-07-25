import boto3
import json

dynamodb = boto3.resource('dynamodb')
table_name = 'lambda-apigateway'

def lambda_handler(event, context):
    # Récupération des paramètres de la requête
    operation = event.get('operation')
    payload = event.get('payload')

    # Traitement de la requête
    if operation == 'create':
        response = create_item(payload)
    elif operation == 'read':
        response = read_item(payload)
    elif operation == 'update':
        response = update_item(payload)
    elif operation == 'delete':
        response = delete_item(payload)
    else:
        return format_response(400, {'message': 'Opération inconnue'})

    return response

def format_response(status_code, body):
    return {
        'statusCode': status_code,
        'headers': {
            'Access-Control-Allow-Origin': '*'
        },
        'body': json.dumps(body)
    }

def create_item(payload):
    table = dynamodb.Table(table_name)
    table.put_item(Item=payload)
    return format_response(201, {'message': 'Item créé'})

def read_item(payload):
    table = dynamodb.Table(table_name)
    response = table.get_item(Key=payload)
    item = response.get('Item')
    if item:
        return format_response(200, item)
    else:
        return format_response(404, {'message': 'Item non trouvé'})

def update_item(payload):
    table = dynamodb.Table(table_name)
    table.update_item(
        Key=payload['Key'],
        UpdateExpression=payload['UpdateExpression'],
        ExpressionAttributeValues=payload.get('ExpressionAttributeValues', {})
    )
    return format_response(200, {'message': 'Item mis à jour'})

def delete_item(payload):
    table = dynamodb.Table(table_name)
    table.delete_item(Key=payload)
    return format_response(200, {'message': 'Item supprimé'})
