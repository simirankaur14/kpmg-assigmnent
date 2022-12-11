variable lambda_block {
    type = map
    description = "lambda_block details"
}

variable api_gateway_block {
    type = map
    description = "apigateway block details"
}

variable api_gateway_integration_block {
    type = map
    description = "apigateway integration details with lambda"
}
variable name_api {
    type = string
    description = "name of rest api"
}
variable description_api {
    type = string
    description = "description of rest api"
}
