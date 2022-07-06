#!/bin/sh -ue
curl $(terraform output -raw s3wwwurl_tsl)
