# AWS SQS Kamelet test

This test verifies the AWS SQS Kamelet source defined in [aws-sqs-source.kamelet.yaml](aws-sqs-source.kamelet.yaml)

## Objectives

The test verifies the AWS SQS Kamelet source by creating a Camel-K integration that uses the Kamelet and listens for messages on the
AWS SQS channel.

This test uses [aws-sqs-docker-image](https://github.com/tplevko/aws-sqs-docker-image) as a test client for extecution of validation steps.

### Test Kamelet source

The test performs the following high level steps:

*Preparation*
- Create a secret on the current namespace holding the AWS SQS credentials
- Link the secret to the test

*Scenario* 
- Create the Kamelet in the current namespace in the cluster
- Create the Camel-K integration that uses the Kamelet
- Wait for the Camel-K integration to start and listen for AWS SQS messages
- Create a new message in the AWS SQS queue
- Verify that the integration has received the message event

*Cleanup*
- Delete the Camel-K integration
- Delete the secret from the current namespacce

## Installation

The test assumes that you have access to a Kubernetes cluster and that the Camel-K operator as well as the YAKS operator is installed
and running.

You can review the installation steps for the operators in the documentation:

- [Install Camel-K operator](https://camel.apache.org/camel-k/latest/installation/installation.html)
- [Install YAKS operator](https://github.com/citrusframework/yaks#installation)

## Preparations

Before you can run the test you have to provide AWS SQS account credentials into the file [aws-sqs-credentials.properties](aws-sqs-credentials.properties). The test will use these credentials to connect to your AWS SQS queue.

When the test is executed the credentials will be automatically added as a secret in the current Kubernetes namespace. The secret is automatically created before the test using
the shell script [prepare-secret.sh](prepare-secret.sh).

*prepare-secret.sh*
```shell script
# create secret from properties file
kubectl create secret generic aws-sqs-credentials --from-file=aws-sqs-credentials.properties

# bind secret to test by name
kubectl label secret aws-sqs-credentials yaks.citrusframework.org/test=aws-sqs-source 
```  

If for any reason this script execution does not work for your OS or environment you may need to run this step manually on your cluster and
remove the prepare script from the [yaks-config.yaml](yaks-config.yaml).

Now you should be ready to run the test!

## Run the test

```shell script
$ yaks test aws-sqs-source.feature
```

You will be provided with the test log output and the test results.
