#!/usr/local/bin/bash

echo "Creating Root CA Keys..."
openssl genrsa -des3 -out ca/ca.key 2048

echo "Generating X509 Certificate for the root CA..."
openssl req -new -x509 -days 10000 -key ca/ca.key -out ca/ca.crt -subj "/C=US/ST=California/L=San Jose/O=Personal, Inc./OU=Root CA/CN=mydomain.com"
