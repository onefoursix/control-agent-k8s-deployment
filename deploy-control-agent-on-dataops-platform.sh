#!/bin/sh

## Set these variables ##################

# ORG_ID -- Your DataOps Platform Org ID
ORG_ID=

# SCH_URL -- Your DataOps Platform URL, for example: https://na01.hub.streamsets.com
SCH_URL=

# CRED_ID -- Your API Credential CRED_ID.  You must have the Provisioning Operator Role
CRED_ID=

# CRED_TOKEN -- Your API Credential CRED_TOKEN
CRED_TOKEN=

# KUBE_NAMESPACE -- The namespace for the deployment; the namespace will be created if it does not exist
KUBE_NAMESPACE=

#######################################


## Get a token for a Control Agent
AGENT_TOKEN=$(curl -s -X PUT -d "{\"organization\": \"${ORG_ID}\", \"componentType\" : \"provisioning-agent\", \"numberOfComponents\" : 1, \"active\" : true}" ${SCH_URL}/security/rest/v1/organization/${ORG_ID}/components --header "Content-Type:application/json" --header "X-Requested-By:SDC" --header "X-SS-REST-CALL:true" --header "X-SS-App-Component-Id:${CRED_ID}" --header "X-SS-App-Auth-Token:${CRED_TOKEN}" | jq '.[0].fullAuthToken')

if [ -z "$AGENT_TOKEN" ]; then
  echo "Error: Failed to generate control agent token."
  echo "Please verify you have Provisioning Operator permissions in SCH"
  exit 1
fi

if [ -z "${KUBE_NAMESPACE}" ]; then
  echo "Error: Namespace is not set ."
  echo "Please set the environment variable KUBE_NAMESPACE"
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
    --from-literal=org=${ORG_ID} \
    --from-literal=sch_url=${SCH_URL} \
    --from-literal=agent_id=${AGENT_ID}

## Create a Service Account to run the Control Agent
kubectl create -f yaml/control-agent-rbac-1.22.yaml

## Deploy the Control Agent
kubectl create -f yaml/control-agent.yaml
