# Jira Kamelet test

This test verifies the Jira Kamelet source defined in [jira-source.kamelet.yaml](jira-source.kamelet.yaml)

## Objectives

The test verifies the jira-source Kamelet by creating a Camel-K integration that uses the Kamelet and listens for new 
Jira issue objects. New issue object is passed to InMemoryChannel, which is bound to logger-sink Kamelet by KameletBinding.

The test performs the following high level steps:

*Preparation*
- Create temporary namespace and install Yaks operator into it
- Install Camel-K operator in temporary namespace
- Create and label secret used by Yaks test
- Create InMemoryChannel messages
- Create logger-sink Kamelet
- Create KameletBinding inmem-to-log, which binds InMemoryChannel messages to logger-sink Kamelet
- Create Camel-K integration jira-to-inmem, which flows from jira-source Kamelet to InMemoryChannel messages (property 
based configuration)

*Scenario Verify resources* 
- Verify that jira-source and logger-sink Kamelets are available
- Verify that KameletBinding inmem-to-log is available
- Verify that integration jira-to-inmem is running 

*Scenario Verify new Jira issue is created* 
- Create new Jira issue via http request
- Verify the issue was created 
- Verify the issue was logged by Camel-K integration inmem-to-log  

*Cleanup*
- Test is run in temporary namespace, which is deleted with all resources after test finished

## Installation

The test assumes that you have access to a Kubernetes cluster. Test creates temporary namespace and installs there both 
Yaks and Camel-K operator.

## Preparations

Before you can run the test you have to provide properties required by jira-source Kamelet into the file [jira-credentials.properties](jira-credentials.properties). 
 
Credentials are used to test the property based configuration of jira-source Kamelet and to create a new Jira issue 
during the test (test assumes you use the "jql" property in format "PROJECT=myprojectname", otherwise change 
appropriately body of the http request in [jira-source.feature](jira-source.feature)).

When the test is executed the credentials will be automatically added as a secret in the temporary Kubernetes namespace. 
The secret is created before the test runs using the shell script [prepare-structure.sh](prepare-structure.sh),
which also prepares the other underlying structure needed to run the test.

Jira-source Kamelet is loaded automatically when Camel-K operator is installed into namespace.

Alternatively, you can execute each step of [prepare-structure.sh](prepare-structure.sh) manually, on a namespace with installed Camel-K and 
Yaks operator. In this case you should change [yaks-config.yaml](yaks-config.yaml) appropriately. 

## Run the test

```shell script
$ yaks test jira-source.feature
```

You can increase number of attempts to run the test by adding: "-e YAKS_CAMELK_MAX_ATTEMPTS=1000"

You will be provided with the test log output and the test results.
