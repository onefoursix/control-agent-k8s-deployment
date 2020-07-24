## Prerequisites and init steps for for EKS

### Prerequisites

- The target EKS cluster should already exist
- The AWS CLI and ````kubectl```` should be installed on the local machine.


### Init steps

If necessary, init the AWS CLI as described [here](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-configure.html)

Execute the following command to initialize your kubectl config for your EKS cluster:
````
$ aws eks --region <your region> update-kubeconfig --name <your EKS cluster name>
````


