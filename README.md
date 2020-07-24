## Control Agent install on Kubernetes

This project provides a quick and easy way to deploy a StreamSets [Control Agent](https://streamsets.com/blog/streamsets-control-hub-kubernetes/) on various Kubernetes clusters.

There are three steps involved:

- Init your environment for your specific k8s provider
- Prepare the install script
- Run the install script

For all environments, you will need credentials for a Control Hub user with rights to create Provisioning Agents.


### Environment-Specific Init Steps:

- For AKS execute the init steps [here](https://github.com/onefoursix/control-agent-k8s-deployment/blob/master/aks.md)

- For EKS execute the init steps [here](https://github.com/onefoursix/control-agent-k8s-deployment/blob/master/eks.md)

- For GKE execute the init steps [here](https://github.com/onefoursix/control-agent-k8s-deployment/blob/master/gke.md)


### Prepare the Script:

Set these variables at the top of the file ````deploy-control-agent.sh````:
````
SCH_ORG=<YOUR-SCH-ORG>
SCH_URL=<YOUR-SCH-URL>
SCH_USER=<YOUR-SCH-USER>
SCH_PASSWORD=<YOUR-SCH-PASSWORD>
KUBE_NAMESPACE=<YOUR-K8S-NAMESPACE>
````
For example, in my environment, I set the script's variables like this:

````
SCH_ORG=globex               
SCH_URL=https://sch.onefoursix.com:18631                
SCH_USER=mark@globex              
SCH_PASSWORD=<redacted>          
KUBE_NAMESPACE=ns1 
````

### Run the script

Execute the script ````deploy-control-agent.sh````
````
$ ./deploy-control-agent.sh
````



The script output should look something like this:
````
$ ./deploy-control-agent-in-aks.sh
namespace/ns1 created
Context "mark-cluster-1" modified.
secret/control-agent-token created
secret/control-agent-secret created
configmap/control-agent-config created
serviceaccount/streamsets-agent created
role.rbac.authorization.k8s.io/streamsets-agent created
rolebinding.rbac.authorization.k8s.io/streamsets-agent created
deployment.apps/control-agent created
````


### Validate the Control Agent
The Control Agent should register itself with Control Hub like this:

![Control Agent](images/control-agent.png)


### How to see what the Control Agent is doing

You can tail the log of the Control Agent pod like this:

````
$ kubectl get pods
NAME                            READY   STATUS    RESTARTS   AGE
control-agent-c8888f646-zsfd6   1/1     Running   0          33m

$ kubectl logs -f control-agent-c8888f646-zsfd6
````

You should see a steady stream of messages like this if the Control Agent is healthy:

````
... Getting Events from DPM
... Getting Events from DPM
... Syncing Deployment Status
... Queuing Event Type : 'DEPLOYMENT_STATUS_EVENT_MULTIPLE' with Payload '{"deploymentStatuses":[]}' for DPM
...
````

