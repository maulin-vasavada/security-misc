#!/usr/local/bin/bash

CA_DIR=./ca
CA_CONF_FILE=ca.conf
CSR_REQUEST_FILE="$1"
OUTPUT_FILE="$2".crt

echo "Signing the CSR Request file "$CSR_REQUEST_FILE" . Output will be available in "$OUTPUT_FILE
openssl ca -config $CA_CONF_FILE -out $OUTPUT_FILE -infiles $CSR_REQUEST_FILE
