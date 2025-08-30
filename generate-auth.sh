#!/bin/bash

# Script to generate basic auth credentials for nginx
# Usage: ./generate-auth.sh <username> <password>

if [ $# -ne 2 ]; then
    echo "Usage: $0 <username> <password>"
    echo "Example: $0 admin mypassword123"
    exit 1
fi

USERNAME=$1
PASSWORD=$2

# Check if htpasswd is available
if ! command -v htpasswd &> /dev/null; then
    echo "htpasswd command not found. Installing apache2-utils..."
    
    # Try to install htpasswd based on the system
    if command -v apt-get &> /dev/null; then
        sudo apt-get update && sudo apt-get install -y apache2-utils
    elif command -v yum &> /dev/null; then
        sudo yum install -y httpd-tools
    elif command -v brew &> /dev/null; then
        brew install httpd
    else
        echo "Could not install htpasswd. Please install apache2-utils (Ubuntu/Debian) or httpd-tools (CentOS/RHEL) manually."
        exit 1
    fi
fi

# Create the .htpasswd file
echo "Generating password for user: $USERNAME"
htpasswd -c nginx/.htpasswd "$USERNAME"

echo "Password file created at nginx/.htpasswd"
echo "You can now start the application with: docker-compose up -d"