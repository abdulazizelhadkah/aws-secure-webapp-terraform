#!/bin/bash

# --- Script Configuration ---
# set -e: Exit immediately if a command exits with a non-zero status.
# set -x: Print commands and their arguments as they are executed.
set -ex

# --- System Setup ---
sudo yum update -y
sudo yum install -y python3 python3-pip

# --- Application Deployment ---
sudo mkdir -p /opt/webapp
sudo cp -r /tmp/webapp/* /opt/webapp/
cd /opt/webapp
/usr/bin/pip3 install -r requirements.txt

# --- Instance Metadata (IMDSv2) ---
# Use IMDSv2 (token-based) for better security and reliability
IMDS_TOKEN=$(curl -s -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")
IMDS_URL="http://169.254.169.254/latest/meta-data"

# Helper function to fetch metadata with the token
fetch_metadata() {
    local path=$1
    curl -s -H "X-aws-ec2-metadata-token: $IMDS_TOKEN" "$IMDS_URL/$path"
}

# --- Fetch Metadata ---
# These calls are now much more reliable
INSTANCE_IP=$(fetch_metadata local-ipv4)
AZ=$(fetch_metadata placement/availability-zone)
INSTANCE_ID_VAL=$(fetch_metadata instance-id)
INSTANCE_TYPE_VAL=$(fetch_metadata instance-type)
HOSTNAME_VAL=$(fetch_metadata hostname)

# This was the failing line. It will now work because $AZ will have a value.
REGION=${AZ::-1}

# --- Export Environment Variables for App ---
export INSTANCE_PRIVATE_IP=$INSTANCE_IP
export AZ=$AZ
export REGION=$REGION
export INSTANCE_ID=$INSTANCE_ID_VAL
export INSTANCE_TYPE=$INSTANCE_TYPE_VAL
export HOSTNAME=$HOSTNAME_VAL

# --- Start Application ---
# Use an absolute path for the log file
sudo chown -R ec2-user:ec2-user /opt/webapp

cd /opt/webapp
nohup python3 app.py > /opt/webapp/app.log 2>&1 &

exit 0