from flask import Flask
import os

app = Flask(__name__)

INSTANCE_IP = os.environ.get('INSTANCE_PRIVATE_IP', 'N/A')
AZ = os.environ.get('AZ', 'N/A')
REGION = os.environ.get('REGION', 'N/A')
INSTANCE_ID = os.environ.get('INSTANCE_ID', 'N/A')
INSTANCE_TYPE = os.environ.get('INSTANCE_TYPE', 'N/A')
HOSTNAME = os.environ.get('HOSTNAME', 'N/A')

@app.route('/')
def hello_world():
    html_output = f"""
    <!doctype html>
    <title>Secure Webapp Backend Status</title>
    <h1>Hello from the Secure Webapp Backend Service!</h1>

    <h2>Deployment Info:</h2>
    <ul>
        <li><strong>Private IP:</strong> {INSTANCE_IP}</li>
        <li><strong>Hostname:</strong> {HOSTNAME}</li>
        <li><strong>Instance ID:</strong> {INSTANCE_ID}</li>
        <li><strong>Instance Type:</strong> {INSTANCE_TYPE}</li>
        <li><strong>Availability Zone:</strong> {AZ}</li>
        <li><strong>Region:</strong> {REGION}</li>
    </ul>
    """
    return html_output

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)