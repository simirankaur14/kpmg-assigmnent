lambda_block = {
    testlambda1 = {
    function_name = "meta_data"
    handler       = "lambda_function.lambda_function.lambda_handler"
    memory_size = 512
    timeout = 360
    runtime = "python3.9"
    filename = "./lambda_function.zip"
    },
    testlambda2 = {
    function_name = "python_code"
    handler       = "lambda_function_2.lambda_function.read_json"
    memory_size = 512
    timeout = 360
    runtime = "python3.9"
    filename = "./lambda_function_2.zip"
    }
}

api_gateway_block = {
    test1 = {
    path_part        = "meta_data"
    http_method      = "GET"
    lamda_ref_name = 512
    },
    test2 = {
    path_part = "python_code"
    http_method      = "GET"
    lamda_ref_name = 512
    }
}

api_gateway_integration_block = {
    test1 = {
    lambda_ref_name = "testlambda1"
    type           = "AWS_PROXY"
    integration_http_method = "POST"
    },
    test2 = {
    lambda_ref_name = "testlambda2"
    type           = "AWS_PROXY"
    integration_http_method = "POST"
    }
}

name_api = "test"
description_api = "test apigateway"