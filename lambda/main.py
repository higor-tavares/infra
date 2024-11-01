import boto3
import os
import json

queue = os.environ['QUEUE_URL']

def lambda_handler(event, context):
   print(f'Webhook event received [{event}')
   sqs = boto3.client('sqs')
   sqs.send_message(
    QueueUrl = queue,
    MessageBody = json.dumps(event)
   )
   print(f'Enqueued the message successfully')
