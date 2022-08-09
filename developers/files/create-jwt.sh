#!/usr/bin/env bash

#
# JWT Encoder Bash Script
#

helpFunction()
{
   echo ""
   echo "Usage: $0 -s secret_key -e user_email"
   echo -e "\t-secret_key Secret key for JWT signing goes here"
   echo -e "\t-user_email User email goes here"
   exit 1 # Exit script after printing help
}

while getopts "s:e:" opt
do
   case "$opt" in
      s) secret="$OPTARG" ;;
      e) email="$OPTARG" ;;
      ?) helpFunction ;; # Print helpFunction in case parameter is non-existent
   esac
done

# Print helpFunction in case parameters are empty
if [ -z "$secret" ] || [ -z "$email" ]
then
   echo "Some or all of the parameters are empty";
   helpFunction
fi


# Static header fields.
header='{
    "typ": "JWT",
    "alg": "HS256"
}'

payload="{"\""user"\"" : "\""$email"\"" }"

base64_encode()
{
    declare input=${1:-$(</dev/stdin)}
    # Use `tr` to URL encode the output from base64.
    printf '%s' "${input}" | base64 | tr -d '=' | tr '/+' '_-' | tr -d '\n'
}

json() {
    declare input=${1:-$(</dev/stdin)}
    printf '%s' "${input}" | jq -c .
}

hmacsha256_sign()
{
    declare input=${1:-$(</dev/stdin)}
    printf '%s' "${input}" | openssl dgst -binary -sha256 -hmac "${secret}"
}

header_base64=$(echo "${header}" | json | base64_encode)
payload_base64=$(echo "${payload}" | json | base64_encode)

header_payload=$(echo "${header_base64}.${payload_base64}")
signature=$(echo "${header_payload}" | hmacsha256_sign | base64_encode)

echo "${header_payload}.${signature}"
