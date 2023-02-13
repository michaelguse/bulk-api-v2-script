#!/bin/bash

if [ $# -ne 2 ]; then
    echo
    echo $0: usage: BulkJob_Update login_creds_file job_param
    echo
    exit 1
fi

# Variable Initialization

# Assign 2nd attribute from command line to jobid variable 
jobid=$2

# By default debugging is disabled
curl_debug=''
#curl_debug='-v'  	 # To add debugging to this script, uncomment this line
#curl_debug='--trace -'  # To enable further debugging (incl. payload tracing - lots of data), uncomment this line

api_version=41.0
now=$(date +%Y%m%d%H%M%S)   #timestamp for unique log files per execution

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

  read -n 1 -p "Press key to refresh job status (q to quit)" key

  if [[ $key = q ]]
  then
      break
  fi
done





  
