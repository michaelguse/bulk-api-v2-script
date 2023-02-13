# bulk-api-2-cli-script
This repository contains a Bash script for the Mac OS platform that provides some automation to establish a Bulk API v2 job request, as described in the [Bulk APi 2.0 PDF](https://resources.docs.salesforce.com/210/latest/en-us/sfdc/pdf/api_bulk_v2.pdf) and the available [Salesforce developer resources](https://developer.salesforce.com/docs/atlas.en-us.api_bulk_v2.meta/api_bulk_v2/introduction_bulk_api_2.htm).

To use the two available scripts, extract this repository as a ZIP file or just clone it directly from here to your local computer.

Both of the scripts require two parameters when calling the scripts. The first parameter in both cases is the name of the file that contains the login credentials. An example login credential file is provided in this repository and is called [login.txt](https://git.soma.salesforce.com/mguse/bulk-api-2-cli-script/blob/master/login.txt). You only need to change the USERNAME and PASSWORD in this file.

## Available Bash shell scripts

### BulkJob_Update.sh

The [BulkJob_Update.sh](https://git.soma.salesforce.com/mguse/bulk-api-2-cli-script/blob/master/BulkJob_Update.sh) script provides a way to perform the following steps for you:

1. Perform login to Salesforce via SOAP request
2. Create Contact object update job via Bulk API 2.0 request
3. Submit CSV data file for the job created in Step 2
4. Update the job status to UploadComplete, which will start the job
5. Retrieve the job status and provide the option to refresh the job status as needed

If you want  to construct a different operation against a different object in Salesforce, the details in Step 2 needs to be changed (please update the JSON in Row 50 as needed):

```javascript
{ "object" : "Contact", "contentType" : "CSV", "operation" : "update" }
```

The above referenced documentation provides you the details on what operations are supported and what additional parameters might be required for the different operations (e.g., the upsert operation will also require an External Identifier reference parameter).

Additionally, if your CSV contains CRLF line endings, you might need to add an additional item to the JSON block, indicating the line ending of the CSV file. Below is an example of how it needs to look in the case of a CSV file with CRLF line endings:
 
```javascript
{ "object" : "Contact", "contentType" : "CSV", "operation" : "update", __"lineEnding" : "CRLF"__ }
```

### checkJobStatus.sh

The [checkJobStatus.sh](https://git.soma.salesforce.com/mguse/bulk-api-2-cli-script/blob/master/checkJobStatus.sh) script provides a standalone way to check on the status of a Bulk API v2 job. It provides a quick way to check the status for a job from the command line. It performs the following steps:

1. Perform login to Salesforce via SOAP request
2. Retrieve the job status and provide the option to refresh the job status as needed

## Dependencies

This script does have a few dependencies on specific commands to be available from your terminal and it was developed and tested on a Mac only. Specifically, these are the dependencies:

* BASH shell
* CURL command
* XMLLINT, SED, TR and GREP command
* [JSON.sh](https://github.com/dominictarr/JSON.sh)

In my case, only the JSON.sh needed to be added to my environment, as all the other dependencies were available by default on my MacBook Air laptop.

## Script support

I hope this README helps with the overall usage of the provided scripts and they are meant to be used as-is and at your own risk. 

But I am happy to assist in case you are running into some unexpected behaviors. Please log your reproducible problem/issue/bug  against the repository as a [New Issue](https://github.com/michaelguse/bulk-api-v2-script/issues/new/choose).


I hope these scripts will be of some help to someone out there.

