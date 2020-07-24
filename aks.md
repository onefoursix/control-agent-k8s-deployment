## Prerequisites and init steps for for AKS

### Prerequisites

- The target AKS cluster should already exist
- The Azure CLI and ````kubectl```` should be installed on the local machine.


### Init steps

Execute the command ```` $ az login```` to login to Azure.

Execute the following command to initialize your kubectl config:
````
$ az aks get-credentials --resource-group <YOUR-RESOURCE-GROUP> --name <YOUR-CLUSTER-NAME>
````

If any resources of the same name already exist in your local kubeconfig the  ````get-credentials```` command will prompt to see if you want to overwrite them.


