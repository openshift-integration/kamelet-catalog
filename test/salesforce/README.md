# Salesforce Kamelet test

This test verifies the Salesforce Kamelet source defined in [salesforce-source.kamelet.yaml](salesforce-source.kamelet.yaml)

## Objectives

The test verifies the Salesforce Kamelet source by creating a Camel-K integration that uses the Kamelet and listens for Case objects on the
Salesforce account.

### Test Kamelet source

The test performs the following high level steps:

*Preparation*
- Create a secret on the current namespace holding the Salesforce credentials
- Link the secret to the test

*Scenario* 
- Obtain an authorization token from Salesforce login
- Obtain the account id for the Salesforce account
- Create the Kamelet in the current namespace in the cluster
- Create the Camel-K integration that uses the Kamelet
- Wait for the Camel-K integration to start and listen for Case objects
- Create a new Case object on the Salesforce API
- Verify that the integration has received the Case object event

*Cleanup*
- Delete the Camel-K integration
- Delete the secret from the current namespacce

### Test KameletBinding

The test performs the following high level steps:

*Preparation*
- Create a secret on the current namespace holding the Salesforce credentials
- Link the secret to the test

*Scenario* 
- Obtain an authorization token from Salesforce login
- Obtain the account id for the Salesforce account
- Create the Kamelet in the current namespace in the cluster
- Create the KameletBinding that binds the Salesforce source to a Http URI
- Create a new Http service that exposes the URI endpoint
- Wait for services to start properly
- Create a new Case object on the Salesforce API
- Verify that the Http URI service endpoint has received the Case object event

*Cleanup*
- Delete the KameletBinding
- Delete the Http URI service endpoint
- Delete the secret from the current namespacce

## Installation

The test assumes that you have access to a Kubernetes cluster and that the Camel-K operator as well as the YAKS operator is installed
and running.

You can review the installation steps for the operators in the documentation:

- [Install Camel-K operator](https://camel.apache.org/camel-k/latest/installation/installation.html)
- [Install YAKS operator](https://github.com/citrusframework/yaks#installation)

## Preparations

Before you can run the test you have to provide Salesforce account credentials into the file [salesforce-credentials.properties](salesforce-credentials.properties). The
test will use these credentials to connect to your Salesforce account.

When the test is executed the credentials will be automatically added as a secret in the current Kubernetes namespace. The secret is automatically created before the test using
the shell script [prepare-secret.sh](prepare-secret.sh).

*prepare-secret.sh*
```shell script
# create secret from properties file
kubectl create secret generic salesforce-credentials --from-file=salesforce-credentials.properties

# bind secret to test by name
kubectl label secret salesforce-credentials yaks.citrusframework.org/test=salesforce-source 
```  

If for any reason this script execution does not work for your OS or environment you may need to run this step manually on your cluster and
remove the prepare script from the [yaks-config.yaml](yaks-config.yaml).

Now you should be ready to run the test!

## Run the test

```shell script
$ yaks test salesforce-source.feature
$ yaks test salesforce-binding.feature
```

You will be provided with the test log output and the test results.
