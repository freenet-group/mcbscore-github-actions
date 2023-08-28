#!/bin/bash
set -e
if [ $# -lt 3 ]; then
  echo "USAGE: $0 <clientId> <clientSecret> <tokenUrl>"
  exit 1
fi
clientId=$1
clientSecret=$2
tokenUrl=$3

curlResult=$(curl -sw %{http_code} -X POST $3 --header 'Content-Type: application/x-www-form-urlencoded' \
  --data-urlencode 'grant_type=client_credentials' \
  --data-urlencode "client_id=$clientId" \
  --data-urlencode "client_secret=$clientSecret" \
  --data-urlencode 'scope=openid')

status="${curlResult:${#curlResult}-3}"
if [[ $status == "200" ]]; then
  response="${curlResult:0:${#curlResult}-3}"
  accessToken=$(echo $response | grep -Po '"access_token": *\K"[^"]*"' | sed 's/"//g')
  echo "$accessToken"
else
  echo "Authentifizierung fehlgeschlagen!"
  echo $curlResult
  exit 1
fi