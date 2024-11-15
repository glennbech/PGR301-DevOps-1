import base64
import boto3
import json
import random
import os

# Set up AWS clients for Bedrock and S3
bedrock_client = boto3.client("bedrock-runtime", region_name="us-east-1")
s3_client = boto3.client("s3")

# Get environment variables for S3 bucket name and candidate nr
BUCKET_NAME = os.getenv('BUCKET_NAME')
CANDIDATE_NR = os.getenv('CANDIDATE_NR')

# Lambda handler function
def lambda_handler(event, context):
    try:
        # Get the prompt from the HTTP body (POST request)
        body = json.loads(event.get('body', '{}'))
        prompt = body.get('prompt', 'No prompt provided')

        # Check if the prompt is missing
        if prompt == 'No prompt provided':
            return {
                "statusCode": 400,
                "body": json.dumps({
                    "message": "Prompt is missing from the request body."
                })
            }

        # Generate a random seed to create unique images
        seed = random.randint(0, 2147483647)

        # Prepare request for Bedrock model
        native_request = {
            "taskType": "TEXT_IMAGE",
            "textToImageParams": {"text": prompt},
            "imageGenerationConfig": {
                "numberOfImages": 1,
                "quality": "standard",
                "cfgScale": 8.0,
                "height": 1024,
                "width": 1024,
                "seed": seed,
            }
        }

        # Call the Bedrock model to generate the image
        response = bedrock_client.invoke_model(
            modelId="amazon.titan-image-generator-v1", 
            body=json.dumps(native_request)
        )
        model_response = json.loads(response["body"].read())

        # Extract and decode the Base64 image data
        base64_image_data = model_response["images"][0]
        image_data = base64.b64decode(base64_image_data)

        # Create S3 path to upload the image
        s3_key = f"{CANDIDATE_NR}/titan_{seed}.png"

        # Upload the image to S3
        s3_client.put_object(Bucket=BUCKET_NAME, Key=s3_key, Body=image_data)

        # Return a success message
        return {
            "statusCode": 200,
            "body": json.dumps({
                "message": "Image generated and uploaded successfully!",
                "s3_key": s3_key
            })
        }

    except Exception as e:
        # Return an error message if something goes wrong
        return {
            "statusCode": 500,
            "body": json.dumps({
                "message": "An error occurred.",
                "error": str(e)
            })
        }
