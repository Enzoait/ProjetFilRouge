import AWS from 'aws-sdk'

const dynamodb = new AWS.DynamoDB.DocumentClient()
const TABLE_NAME = process.env.TABLE_NAME || 'todos'

export const handler = async (event) => {
  const method = event.httpMethod
  const path = event.path
  const body = event.body ? JSON.parse(event.body) : {}

  try {
    if (method === 'GET' && path === '/todos') {
      return await getTodos()
    }

    if (method === 'POST' && path === '/todos') {
      return await createTodo(body)
    }

    if (method === 'PUT' && path.startsWith('/todos/')) {
      const id = path.split('/').pop()
      return await updateTodo(id, body)
    }

    if (method === 'DELETE' && path.startsWith('/todos/')) {
      const id = path.split('/').pop()
      return await deleteTodo(id)
    }

    return response(404, { message: 'Not Found' })
  } catch (err) {
    console.error(err)
    return response(500, { message: 'Server Error' })
  }
}

// === Handlers ===

const getTodos = async () => {
  const result = await dynamodb.scan({ TableName: TABLE_NAME }).promise()
  return response(200, result.Items)
}

const createTodo = async (todo) => {
  if (!todo.id || !todo.title) {
    return response(400, { message: 'Missing id or title' })
  }

  await dynamodb.put({
    TableName: TABLE_NAME,
    Item: todo
  }).promise()

  return response(201, todo)
}

const updateTodo = async (id, data) => {
  await dynamodb.update({
    TableName: TABLE_NAME,
    Key: { id },
    UpdateExpression: 'SET title = :t, completed = :c',
    ExpressionAttributeValues: {
      ':t': data.title || '',
      ':c': data.completed ?? false
    }
  }).promise()

  return response(200, { message: 'Updated' })
}

const deleteTodo = async (id) => {
  await dynamodb.delete({
    TableName: TABLE_NAME,
    Key: { id }
  }).promise()

  return response(200, { message: 'Deleted' })
}

// === Response helper ===

const response = (statusCode, body) => ({
  statusCode,
  headers: {
    'Content-Type': 'application/json',
    'Access-Control-Allow-Origin': '*'
  },
  body: JSON.stringify(body)
})

// import {
//   DynamoDBDocumentClient,
//   PutCommand,
//   GetCommand,
//   UpdateCommand,
//   DeleteCommand,
// } from "@aws-sdk/lib-dynamodb";
// import { DynamoDBClient } from "@aws-sdk/client-dynamodb";

// const ddbClient = new DynamoDBClient({ region: "eu-west-1" });
// const ddbDocClient = DynamoDBDocumentClient.from(ddbClient);

// // Define the name of the DDB table to perform the CRUD operations on
// const tablename = "lambda-apigateway";

// /**
//  * Provide an event that contains the following keys:
//  *
//  *   - operation: one of 'create,' 'read,' 'update,' 'delete,' or 'echo'
//  *   - payload: a JSON object containing the parameters for the table item
//  *     to perform the operation on
//  */
// export const handler = async (event) => {
//   let body;

//   // Vérifier si event.body est une chaîne JSON, et la parser
//   try {
//     body = typeof event.body === "string" ? JSON.parse(event.body) : event.body;
//   } catch (err) {
//     return {
//       statusCode: 400,
//       body: JSON.stringify({
//         message: "Invalid JSON in request body",
//         error: err.message,
//       }),
//     };
//   }

//   const operation = body?.operation;
//   const payload = body?.payload;

//   if (!operation) {
//     return {
//       statusCode: 500,
//       body: JSON.stringify({
//         message: "Internal server error",
//         error: "Missing 'operation' in request body",
//       }),
//     };
//   }

//   if (!payload) {
//     return {
//       statusCode: 500,
//       body: JSON.stringify({
//         message: "Internal server error",
//         error: "Missing 'payload' in request body",
//       }),
//     };
//   }

//   payload.TableName = tablename;

//   try {
//     let response;

//     switch (operation) {
//       case "create":
//         response = await ddbDocClient.send(new PutCommand(payload));
//         break;
//       case "read":
//         response = await ddbDocClient.send(new GetCommand(payload));
//         break;
//       case "update":
//         response = await ddbDocClient.send(new UpdateCommand(payload));
//         break;
//       case "delete":
//         response = await ddbDocClient.send(new DeleteCommand(payload));
//         break;
//       case "echo":
//         response = payload;
//         break;
//       default:
//         return {
//           statusCode: 400,
//           body: JSON.stringify({ message: `Unknown operation '${operation}'` }),
//         };
//     }

//     return {
//       statusCode: 200,
//       body: JSON.stringify({ message: "Success", data: response }),
//     };
//   } catch (err) {
//     return {
//       statusCode: 500,
//       body: JSON.stringify({
//         message: "Internal server error",
//         error: err.message,
//       }),
//     };
//   }
// };
