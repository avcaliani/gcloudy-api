# 🥳 GCloudy 4Fun
By Anthony Vilarim Caliani

[![#](https://img.shields.io/badge/licence-MIT-lightseagreen.svg)](#) [![#](https://img.shields.io/badge/runtime-nodejs8-green.svg)](#)


## First Steps
Let's prepare our development environment by signing in to GCloud and then selecting your project
```bash
gcloud init
```

Before you proceed make sure that everything is updated
```bash
gcloud components update
```

Then there is a `.env` file in project's root path, there you must set some variables like:
- `PROJECT_ID`
- `PROJECT_NUMBER`
- `PROJECT_REGION`
- `API_KEY`

The `PROJECT_ID` and the `PROJECT_NUMBER` can be found on project's page at GCP. The `PROJECT_REGION` is own your own, you decide where to deploy the project services, functions and etc... Finally to create an `API_KEY` follow this [GCP Tutorial](https://developers.google.com/places/web-service/get-api-key?hl=pt-br)


Well buddy... Now, you are ready to go! But remember that...

> _🧙‍♂️ "If in doubt... Always follow your nose" - Gandalf_


## HTTP Cloud Function

Now you are going to deploy a cloud function and then you will try it using your logged account credetials
```bash
./functions/api-process/function.sh --deploy --try
# If something like this appear to you...
#   "Allow unauthenticated invocations of new function [process-request]? (y/N)?"
# Say "No"!
```

Let's supose that you want to remove this function, what should you do?
```bash 
./functions/api-process/function.sh --remove
# If something like this appear to you...
#   "Do you want to continue (Y/n)?"
# Say "Yes"!
```

> You can see the functions in [GCP Console](https://console.cloud.google.com/functions/list).

## Endpoint Service
#TODO heheheheh


## Related Links
#TODO hehehe
