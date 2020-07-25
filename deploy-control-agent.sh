#!/bin/sh

## Set these variables 
SCH_ORG=               # Your Control Hub Org
SCH_URL=               # If using StreamSets Cloud use https://cloud.streamsets.com 
SCH_USER=              # should be of the form:  user@org  and have rights to create Provisioning Tokens
SCH_PASSWORD=          # The password for the Control Hub User
KUBE_NAMESPACE=        # The namespace for the deployment; the namespace will be created if it does not exist

## Get auth token from Control Hub
SCH_TOKEN=$(curl -s -X POST -d "{\"userName\":\"${SCH_USER}\", \"password\": \"${SCH_PASSWORD}\"}" ${SCH_URL}/security/public-rest/v1/authentication/login --header "Content-Type:application/json" --header "X-Requested-By:SDC" -c - | sed -n '/SS-SSO-LOGIN/p' | perl -lane 'print $F[$#F]')
if [ -z "$SCH_TOKEN" ]; then
  echo "Failed to login to Control Hub."
  echo "Please check your SCH login URL and credentials"
  exit 1
fi

## Use the auth token to get a token for a Control Agent
AGENT_TOKEN=$(curl -s -X PUT -d "{\"organization\": \"${SCH_ORG}\", \"componentType\" : \"provisioning-agent\", \"numberOfComponents\" : 1, \"active\" : true}" ${SCH_URL}/security/rest/v1/organization/${SCH_ORG}/components --header "Content-Type:application/json" --header "X-Requested-By:SDC" --header "X-SS-REST-CALL:true" --header "X-SS-User-Auth-Token:${SCH_TOKEN}" | jq '.[0].fullAuthToken')

if [ -z "$AGENT_TOKEN" ]; then
  echo "Failed to generate control agent token."
  echo "Please verify you have Provisioning Operator permissions in SCH"
  exit 1
fi

## Create Namespace if it does not exist
if kubectl get namespaces | grep  "${KUBE_NAMESPACE} " | grep -q Active
then
  echo "Using existing namespace "${KUBE_NAMESPACE};
else
  kubectl create namespace ${KUBE_NAMESPACE};
fi

## Set Context
kubectl config set-context $(kubectl config current-context) --namespace=${KUBE_NAMESPACE}

## Store the Control Agent token in a secret
kubectl create secret generic control-agent-token \
    --from-literal=dpm_agent_token_string=${AGENT_TOKEN}

## Create a secret for the Control Agent to use
kubectl create secret generic control-agent-secret

## Generate a UUID for the Control Agent
AGENT_ID=$(uuidgen)

## Store connection properties in a configmap for the Control Agent
kubectl create configmap control-agent-config \
    --from-literal=org=${SCH_ORG} \
    --from-literal=sch_url=${SCH_URL} \
    --from-literal=agent_id=${AGENT_ID}

## Create a Service Account to run the Control Agent
kubectl create -f yaml/control-agent-rbac.yaml

## Deploy the Control Agent
kubectl create -f yaml/control-agent.yaml
