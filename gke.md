## Prerequisites and init steps for for GKE

### Prerequisites

- The target GKE cluster should already exist
- The gcloud CLI should be installed and initialized on the local machine
- ````kubectl```` should be installed on the local machine.


### Init steps

Run this command to see what (if any) contexts are already in your kubectl config:

````
$ kubectl config get-contexts
````

If you are using a cluster that already has a context defined, run the command:
````
$ kubectl config use-context <YOUR-CONTEXT-NAME>
````

On the other hand, if your local kubectl config does not have a context for the cluster you wish to use, run the following command:
````
$ gcloud container clusters get-credentials <CLUSTER-NAME>  --project <PROJECT-NAME>

````




