# Slack Kamelet test

This test verifies the Slack Kamelet source defined in [slack-source.kamelet.yaml](slack-source.kamelet.yaml)

## Objectives

The test verifies the Slack Kamelet source by creating a Camel-K integration that uses the Kamelet and listens for messages on the
Slack channel.

### Test Kamelet source

The test performs the following high level steps:

*Preparation*
- Create a secret on the current namespace holding the Slack credentials
- Link the secret to the test

*Scenario* 
- Create the Kamelet in the current namespace in the cluster
- Create the Camel-K integration that uses the Kamelet
- Wait for the Camel-K integration to start and listen for Slack messages
- Create a new message on the Slack channel
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

Before you can run the test you have to provide Slack account credentials into the file [slack-credentials.properties](slack-credentials.properties). The
test will use these credentials to connect to your Slack channel.

When the test is executed the credentials will be automatically added as a secret in the current Kubernetes namespace. The secret is automatically created before the test using
the shell script [prepare-secret.sh](prepare-secret.sh).

*prepare-secret.sh*
```shell script
# create secret from properties file
kubectl create secret generic slack-credentials --from-file=slack-credentials.properties

# bind secret to test by name
kubectl label secret slack-credentials yaks.citrusframework.org/test=slack-source 
```  

If for any reason this script execution does not work for your OS or environment you may need to run this step manually on your cluster and
remove the prepare script from the [yaks-config.yaml](yaks-config.yaml).

Now you should be ready to run the test!

## Run the test

```shell script
$ yaks test slack-source.feature
```

You will be provided with the test log output and the test results.
