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
        response = {'statusCode': 400, 'body': json.dumps({'message': 'Opération inconnue'})}

    return response

def create_item(payload):
    table = dynamodb.Table(table_name)
    response = table.put_item(Item=payload)
    return {'statusCode': 201, 'body': json.dumps({'message': 'Item créé'})}

def read_item(payload):
    table = dynamodb.Table(table_name)
    response = table.get_item(Key=payload)
    return {'statusCode': 200, 'body': json.dumps(response['Item'])}

def update_item(payload):
    table = dynamodb.Table(table_name)
    response = table.update_item(Key=payload['Key'], UpdateExpression=payload['UpdateExpression'])
    return {'statusCode': 200, 'body': json.dumps({'message': 'Item mis à jour'})}

def delete_item(payload):
    table = dynamodb.Table(table_name)
    response = table.delete_item(Key=payload)
    return {'statusCode': 200, 'body': json.dumps({'message': 'Item supprimé'})}