#!/bin/sh -ue
URL_TSL=$(terraform output -raw s3wwwurl_tsl)
URL=$(terraform output -raw s3wwwurl)
OBJECTURL=$(terraform output -raw objecturl)

curl "$URL_TSL"
echo ----
curl "${URL_TSL}subdir/"
echo ----
echo '*** fail'
curl "$URL"
echo ----
echo '*** fail??? ***'
curl "$URL"

echo
