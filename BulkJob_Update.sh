#!/bin/bash

if [ $# -ne 2 ]; then
    echo
    echo $0: usage: BulkJob_Update login_creds_file csv_update_data_file
    echo
    exit 1
fi

# By default debugging is disabled
curl_debug=''

# To debug the script, use the following
#curl_debug='-v'

# To enable further debugging (incl. payload tracing - lots of data) , use the following
#curl_debug='--trace -'

# Intialized Variables
api_version=41.0
now=$(date +%Y%m%d%H%M%S) 	#timestamp for unique log files per execution

echo ===
echo === [$(date "+%Y-%m-%d %H:%M:%S")] - Retrieve access token from Salesforce sandbox environment 
echo ===
curl $curl_debug \
  https://test.salesforce.com/services/Soap/u/$api_version \
  -H "Content-Type: text/xml; charset=UTF-8" \
  -H "SOAPAction: login" \
  -d @"$1" \
  > $now_login_response.xml

echo ===
token=$(xmllint --format login_response_$now.xml | sed -ne '/<sessionId>/s#\s*<[^>]*>\s*##gp')
echo === Token: $token

echo ===
server=$(xmllint --format login_response_$now.xml | sed -ne '/<serverUrl>/s#\s*<[^>]*>\s*##gp' | tr "/" "\n" | grep salesforce.com )
echo === Server: $server

echo ===
echo === [$(date "+%Y-%m-%d %H:%M:%S")] - Create Bulk API v2 update job ... 
echo ===
curl $curl_debug \
  https://$server/services/data/v$api_version/jobs/ingest/ \
  -X POST \
  -H "Content-Type: application/json; charset=UTF-8" \
  -H "Accept: application/json" \
  -H "Authorization: Bearer $token" \
  -d '{ "object" : "Contact", "contentType" : "CSV", "operation" : "update" }' \
  > $now_create_job_response.txt

JSON.sh -l < $now_create_job_response.txt

echo ===
jobid=$(cat create_job_response_$now.txt | JSON.sh -b | grep 'id' | cut -f 2 | cut -d '"' -f 2)
echo === JobId: $jobid

echo ===
echo === [$(date "+%Y-%m-%d %H:%M:%S")] - Upload CSV file for job ... 
echo ===
curl \
  https://$server/services/data/v$api_version/jobs/ingest/$jobid/batches/ \
  -X PUT \
  -H "Content-Type: text/csv" \
  -H "Accept: application/json" \
  -H "Authorization: Bearer $token" \
  --data-binary @"$2" \

echo ===
echo === [$(date "+%Y-%m-%d %H:%M:%S")] - Close the job to start processing ... 
echo ===
curl $curl_debug \
  https://$server/services/data/v$api_version/jobs/ingest/$jobid/ \
  -X PATCH \
  -H "Content-Type: application/json; charset=UTF-8" \
  -H "Accept: application/json" \
  -H "Authorization: Bearer $token" \
  -d '{ "state" : "UploadComplete" }' \
  > $now_close_job_response.txt

JSON.sh -l < $now_close_job_response.txt

while :
do
	echo ===
	echo === [$(date "+%Y-%m-%d %H:%M:%S")] - Get job status ... 
	echo ===
	curl \
	  https://$server/services/data/v$api_version/jobs/ingest/$jobid/ \
	  -H "Content-Type: application/json; charset=UTF-8" \
	  -H "Accept: application/json" \
	  -H "Authorization: Bearer $token" \
	  | JSON.sh -l

  echo .
  read -n 1 -p "Press key to refresh job status (q to quit)" key

  clear

  if [[ $key = q ]]
  then
      break
  fi
done





  
