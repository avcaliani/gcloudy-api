#!/bin/bash -e
# @script       function.sh
# @author       Anthony Vilarim Caliani
# @contact      github.com/avcaliani
#
# @description
# Script to deploy, try, add to IAM policy and remove a Google Cloud Function.
#
# @usage
# ./funtion.sh [ --deploy | --try | --auth-iam | --remove ]
#
BASE_DIR="$(dirname $0)"
ARROW="\033[1;32m◉\033[00m"
ERROR="\033[1;31m◉\033[00m"

source $BASE_DIR/../../.env
FUNC_NAME="process-request"
FUNC_REGION=${PROJECT_REGION:-"us-central1"}
FUNC_RUNTIME="nodejs8"


echo '
   ___  ___ _             _ 
  / __|/ __| |___ _  _ __| |
 | (_ | (__| / _ \ || / _` |
  \___|\___|_\___/\_,_\__,_|'
echo -e "
$ARROW Project 
   $ARROW ID: $PROJECT_ID
   $ARROW Number: $PROJECT_NUMBER
   $ARROW Region: $PROJECT_REGION
$ARROW Function
   $ARROW Name: $FUNC_NAME
   $ARROW Region: $FUNC_REGION
   $ARROW Runtime: $FUNC_RUNTIME
"

cd "$BASE_DIR"

for arg in "$@"
do
    case $arg in
        --deploy)
        echo -e ""
        echo -e "$ARROW Deploying function..."
        gcloud functions deploy "$FUNC_NAME" \
            --runtime "$FUNC_RUNTIME" \
            --trigger-http \
            --entry-point "main" \
            --region="$FUNC_REGION" \
            --project "$PROJECT_ID"
        shift
        ;;

        --try)
        echo -e ""
        echo -e "$ARROW Calling function via HTTP..."
        curl -i -X POST \
            -H "Authorization: Bearer $(gcloud auth print-identity-token)" \
            -H "Content-Type: application/json" \
            -d '{ "owner": "anthony" }' \
            "https://$FUNC_REGION-$PROJECT_ID.cloudfunctions.net/$FUNC_NAME"
        
        echo -e "\n"
        echo -e "$ARROW Reading function logs..."
        sleep 10
        gcloud functions logs read "$FUNC_NAME"
        shift
        ;;

        --auth-iam)
        echo -e ""
        echo -e "$ARROW Allowing project compute service account to access the coud function..."
        gcloud functions add-iam-policy-binding "$FUNC_NAME" \
            --member "serviceAccount:$PROJECT_NUMBER-compute@developer.gserviceaccount.com" \
            --role "roles/cloudfunctions.invoker" \
            --region="$FUNC_REGION" \
            --project "$PROJECT_ID"
        shift
        ;;

        --remove)
        echo -e ""
        echo -e "$ARROW Deleting function..."
        gcloud functions delete "$FUNC_NAME"
        shift
        ;;

        *)
        echo -e "$ERROR Invalid argument '$1'"
        shift
        ;;
    esac
done

cd -
exit 0