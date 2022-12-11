# kpmg-assigmnent

Simple 3-tier application using AWS Lambda and AWS Gateway services.
POSTMAN will act as our presentation layer and generate a HTTP request which will be received by the API Gateway and according to our request URL, it will forward the request to the relevant Lambda Function. The lambda function will process the data and provide the gateway with the necessary response(snippet attched).

Apigateway is integrated with 2 lambda functions ( metadata is for implementing second challenge and python_code is for third challenge)
