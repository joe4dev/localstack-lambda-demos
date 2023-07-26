def lambda_handler(event, context):
    # import debugpy
    # debugpy.listen(("0.0.0.0", 19891))
    # debugpy.wait_for_client()  # blocks execution until client is attached

    body = {
        "num1": 10,
        "num2": 10,
    }
    product = body["num1"] * body["num2"]
    response = {
        "statusCode": 200,
        "body": f"The product of {body['num1']} and {body['num2']} is {product}",
    }
    return response
