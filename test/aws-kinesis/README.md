# AWS Kinesis Kamelet test

This test verifies the AWS Kinesis Kamelet source defined in [aws-kinesis-source.kamelet.yaml](aws-kinesis-source.kamelet.yaml)

## Objectives

The test verifies the AWS Kinesis Kamelet source by creating a Camel-K integration that uses the Kamelet and listens for messages on the
AWS Kinesis data stream.

### Test Kamelet source

The test performs the following high level steps:

*Preparation*
- Create a secret on the current namespace holding the AWS Kinesis credentials
- Link the secret to the test

*Scenario* 
- Create a new AWS Kinesis data stream for testing
- Create the Kamelet in the current namespace in the cluster
- Create the Camel-K integration that uses the Kamelet
- Wait for the Camel-K integration to start and listen for AWS Kinesis data stream
- Create a new message on the AWS Kinesis data stream
- Verify that the integration has received the message event

*Cleanup*
- Delete the AWS Kinesis data stream
- Delete the Camel-K integration
- Delete the secret from the current namespace

## Installation

The test assumes that you have access to a Kubernetes cluster and that the Camel-K operator as well as the YAKS operator is installed
and running.

You can review the installation steps for the operators in the documentation:

- [Install Camel-K operator](https://camel.apache.org/camel-k/latest/installation/installation.html)
- [Install YAKS operator](https://github.com/citrusframework/yaks#installation)

## Preparations

Before you can run the test you have to provide AWS Kinesis account credentials.
 
The account information should be added into the file [aws-kinesis-credentials.properties](aws-kinesis-credentials.properties) 
and [.aws/credentials](.aws/credentials). If you want to use a AWS region other than `us-east-1` please also change the region setting in
[.aws/config](.aws/config). 

The test will use the account credentials to create a new AWS Kinesis data stream and send data to it.

When the test is executed the credentials will be automatically added as a secret in the current Kubernetes namespace. The secret is automatically created before the test using
the shell script [prepare-secret.sh](prepare-secret.sh).

*prepare-secret.sh*
```shell script
# create secret from properties file
kubectl create secret generic aws-kinesis-credentials --from-file=aws-kinesis-credentials.properties

# bind secret to test by name
kubectl label secret aws-kinesis-credentials yaks.citrusframework.org/test=aws-kinesis-source 
```  

If for any reason this script execution does not work for your OS or environment you may need to run this step manually on your cluster and
remove the prepare script from the [yaks-config.yaml](yaks-config.yaml).

Now you should be ready to run the test!

## Run the test

```shell script
$ yaks test aws-kinesis-source.feature
```

You will be provided with the test log output and the test results.
