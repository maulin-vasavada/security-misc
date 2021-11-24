#!/usr/local/bin/bash

CA_DIR=$1
CA_CONF=$2

echo "CA directory is "$CA_DIR

echo "Creating ca config in $CA_CONF ..."

echo "
[ ca ]
default_ca = ca_default
[ ca_default ]
dir = $CA_DIR
certs = \$dir
new_certs_dir = \$dir/ca.db.certs
database = \$dir/ca.db.index
serial = \$dir/ca.db.serial
RANDFILE = \$dir/ca.db.rand
certificate = \$dir/ca.crt
private_key = \$dir/ca.key
default_days = 365
default_crl_days = 30
default_md = md5
preserve = no
policy = generic_policy
[ generic_policy ]
countryName = optional
stateOrProvinceName = optional
localityName = optional
organizationName = optional
organizationalUnitName = optional
commonName = optional
emailAddress = optional
" > $CA_CONF

echo "Setting up $CA_DIR directory'..."
mkdir $CA_DIR
cd $CA_DIR
mkdir ca.db.certs
touch ca.db.index
echo "1234" > ca.db.serial
