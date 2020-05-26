# 🥳 GCloudy 4Fun
By Anthony Vilarim Caliani

[![#](https://img.shields.io/badge/licence-MIT-lightseagreen.svg)](#) [![#](https://img.shields.io/badge/runtime-nodejs8-green.svg)](#)

This project is about an API on Cloud Endpoints with a Google Cloud Functions backend.

## First Steps
Let's prepare our development environment by signing in to GCloud and then selecting your project.
```bash
gcloud init
```

Before you proceed make sure that everything is up to date.
```bash
gcloud components update
```

Then there is a `.env` file in project's root path, there you must set values to some variables like:
- `PROJECT_ID`
- `PROJECT_NUMBER`
- `PROJECT_REGION`
- `API_KEY`

The `PROJECT_ID` and the `PROJECT_NUMBER` can be found on the project's page at GCP. The `PROJECT_REGION` is on your own, you decide where to deploy the project services, functions and etc... Finally to create an `API_KEY` follow this [GCP Tutorial](https://developers.google.com/places/web-service/get-api-key).

Well buddy... Now, you are ready to go! But remember that...
> _🧙‍♂️ "If in doubt... Always follow your nose" - Gandalf_


## HTTP Cloud Function
Now you are going to deploy a cloud function and then you are going to try it using your logged account credentials.
```bash
./functions/process-request/function.sh --deploy --try
# If something like this appear to you...
#   Allow unauthenticated invocations of new function [process-request]? (y/N)?
# Say NO!
```

Let's suppose that you want to remove this function, what should you do?
```bash 
./functions/process-request/function.sh --remove
```


## Endpoint Service
Cool, now that you deployed the cloud function we are going to create an _"Endpoint Service"_.<br>
First, things first... Let's create some variables to help you during the process, okay?
```bash
# Import variables from .env file 
source .env

# Create the endpoint service name
ENDPOINT_SERVICE_NAME="$PROJECT_ID-api"

# Define the default region to deploy the services, resources and etc...
gcloud config set run/region "$PROJECT_REGION"
```


### Once for each different endpoint...
> This step will happen only once for each new endpoint that you create.

Deploy the endpoint service. Initially you may think that nothing has happened, but in the next steps you will see the difference.
```bash
# Obs! Maybe it will appear to you... If it appears, say YES!
#   API [run.googleapis.com] not enabled on project [xxx].
#   Would you like to enable and retry (this will take a few minutes)? (y/N)?
gcloud run deploy "$ENDPOINT_SERVICE_NAME" \
    --image="gcr.io/endpoints-release/endpoints-runtime-serverless:2" \
    --allow-unauthenticated \
    --platform managed \
    --project "$PROJECT_ID"
```

This first step will give you one important information, the _"endpoint hostname"_.<br>
So, let's save this information to use it after.
```bash
# The command above might output some logs like this...
#   Service [ENDPOINT_SERVICE_NAME] revision [ENDPOINT_REVISION] has been deployed and is serving 100 percent of traffic at https://YOUR_ENDPOINT_HOSTNAME
# Then, create a variable that contains the value of your endpoint hostname
endpoint_hostname="YOUR_ENDPOINT_HOSTNAME"
```

Before you move on, check if your endpoint is available on _"services list"_.
```bash
gcloud run services list --platform managed
```


### Every time for a new endpoint version...
> The next steps will happen everytime that you want to deploy a new version of an existing endpoint.  

Now, you have to update the _[OpenAPI](https://www.openapis.org/)_ file with your project values.
```bash 
cd endpoints && mkdir target && cp *.yaml target/functions.yaml
sed -i -e "s/@@ENDPOINT_SERVICE_NAME@@/$ENDPOINT_SERVICE_NAME/g" target/functions.yaml
sed -i -e "s/@@ENDPOINT_HOSTNAME@@/$endpoint_hostname/g" target/functions.yaml
sed -i -e "s/@@PROJECT_REGION@@/$PROJECT_REGION/g" target/functions.yaml
sed -i -e "s/@@PROJECT_ID@@/$PROJECT_ID/g" target/functions.yaml
cd -
```

Now, deploy the endpoint using your _[OpenAPI](https://www.openapis.org/)_ file.
```bash
gcloud endpoints services deploy "endpoints/target/functions.yaml" --project "$PROJECT_ID"
```

The command above will output many cool logs and there exists another important information, the _"configuration id"_<br>
So, let's save this information as well.
```bash
# [ Many interesting logs ...]
# Service Configuration [YOUR_CONFIG_ID] uploaded for service [ENDPOINT_HOSTNAME]
config_id="YOUR_CONFIG_ID"
```

Before you move on, check if your endpoint was created.
```bash
gcloud endpoints services list
```

Cool, now you have to enable some services and let's start by listing the available services.
```bash
# Your service must be in this list named as $endpoint_hostname
gcloud services list
```

Finally, enable the services.
```bash
gcloud services enable servicemanagement.googleapis.com
gcloud services enable servicecontrol.googleapis.com
gcloud services enable endpoints.googleapis.com
gcloud services enable "$endpoint_hostname"
```

Okay, now you need a google script to build the _"image"_ that you are going to deploy.
```bash
curl "https://raw.githubusercontent.com/GoogleCloudPlatform/esp-v2/master/docker/serverless/gcloud_build_image" > endpoints/gcloud_build_image && chmod +x endpoints/gcloud_build_image
```

Then, build the image.
```bash
# If the upload fails try it again in a few minutes
./endpoints/gcloud_build_image -s "$endpoint_hostname" -c "$config_id" -p "$PROJECT_ID"
```

Now, you can deploy the image that you built at the previous step.
```bash
# Obs.: CORS support is active ;)
gcloud run deploy $ENDPOINT_SERVICE_NAME \
    --image="gcr.io/$PROJECT_ID/endpoints-runtime-serverless:$endpoint_hostname-$config_id" \
    --set-env-vars=ESPv2_ARGS=--cors_preset=basic \
    --allow-unauthenticated \
    --platform managed \
    --project "$PROJECT_ID"
```

### Try-Out
Well, let's see if it works...
```bash
curl -i -X POST \
    -H "Content-Type: application/json" \
    -d '{ "developer": "anthony" }' \
    "https://$endpoint_hostname/v1/process?key=$API_KEY"
```

### Clean Up

Let's suppose that you want to remove all created services, what should you do?
```bash
# Removing endpoint service...
gcloud endpoints services delete "$endpoint_hostname" --project "$PROJECT_ID"
# Then, check if your endpoint is not listed anymore 
gcloud endpoints services list

# Remove the service itself
gcloud run services delete "$ENDPOINT_SERVICE_NAME" --platform managed --project "$PROJECT_ID"
# Then, check if your service is not listed anymore 
gcloud run services list --platform managed
```

## That's all folks
Before you go, remember...
> _🧙‍♂️ "A wizard is never late, nor is he early. He arrives precisely when he means to" - Gandalf_

### Related Links
- [GCP: Cloud Functions + Endpoints](https://cloud.google.com/endpoints/docs/openapi/get-started-cloud-functions)
- [Medium: Cloud Functions + API Key](https://medium.com/@akash.mahale/triggering-google-cloud-functions-with-cloud-endpoints-and-api-key-857e94a8a3aa)
