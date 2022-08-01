#!/bin/sh -ue
URL=$(terraform output -raw s3wwwurl_tsl)
curl "$URL"
echo ------
curl "${URL}subdir/"
echo
