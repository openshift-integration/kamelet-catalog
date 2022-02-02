# Extract field Kamelet action test

This test verifies the Kamelet action defined in [extract-field-action.kamelet.yaml](../../extract-field-action.kamelet.yaml)

## Objectives

The test verifies the extract field Kamelet action by creating a Kamelet binding that uses the action. 
In the following the test provides a proper input to the binding and verifies the expected outcome on a Http service endpoint. 

### Test Kamelet action

The test performs the following high level steps:

*Preparation*
- Create and start Http test service as a sink for the Kamelet binding
- Expose the service on a given target port

*Scenario* 
- Configure and create the Kamelet binding that uses the action (timer-source to uri)
- Wait for the Camel K integration to start
- Verify that the binding has performed the Kamelet action as expected by verifying the Http service sink request data

*Cleanup*
- Delete the Kamelet binding
- Delete the test Http service

## Installation

The test assumes that you have access to a Kubernetes cluster and that the Camel K operator as well as the YAKS operator is installed
and running.

You can review the installation steps for the operators in the documentation:

- [Install Camel K operator](https://camel.apache.org/camel-k/latest/installation/installation.html)
- [Install YAKS operator](https://github.com/citrusframework/yaks#installation)

## Preparations

If for any reason this script execution does not work for your OS or environment you may need to run this step manually on your cluster and
remove the prepare script from the [yaks-config.yaml](yaks-config.yaml).

Now you should be ready to run the test!

## Run the test

```shell script
$ yaks run test/extract-field-action
```

You will be provided with the test log output and the test results.
