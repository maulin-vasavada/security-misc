#!/usr/local/bin/bash

GENERATE_CSR=$1
PRIVATE_KEY_FILE="$2".pem
PRIVATE_KEY_PASSWORD=$3
PUBLIC_KEY_FILE="$4".pem
CSR_SUB_OU=""
CSR_FILE=""

if [ "$GENERATE_CSR" == "gencsr" ];then
CSR_SUB_OU=$5
CSR_FILE="csr-$PRIVATE_KEY_FILE".csr
fi


echo "Generate private key..."
openssl genrsa -out $PRIVATE_KEY_FILE -passout pass:$PRIVATE_KEY_PASSWORD 2048

echo "Generate public key..."
openssl rsa -in $PRIVATE_KEY_FILE -pubout -out $PUBLIC_KEY_FILE

if [ "$GENERATE_CSR" == "gencsr" ];then

echo "Generate CSR..."
openssl req -new -key $PRIVATE_KEY_FILE -out $CSR_FILE -subj "/C=US/ST=California/L=San Jose/O=Personal, Inc./OU=$CSR_SUB_OU/CN=mydomain.com"

echo "Verifying CSR..."
openssl req -text -in $CSR_FILE -noout -verify

fi
