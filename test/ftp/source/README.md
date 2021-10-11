# FTP source Kamelet test

This test verifies the Kamelet source defined in [ftp-source.kamelet.yaml](../../ftp-source.kamelet.yaml)

## Objectives

The test verifies the FTP Kamelet source.
The test provides an FTP server instance that the Kamelet can connect to.
The test provides test files on that FTP server instance. 
The source Kamelet will consume the file and send its content to a Http service as a sink.
The test verifies the proper Http request and that the Ftp file content has been processed as expected.

### Test Kamelet source

The test performs the following high level steps:

*Preparation*
- Create and start Http test service as a sink for the Kamelet binding
- Expose the service on a given target port

*Scenario* 
- Configure and create the Kamelet binding that uses the source (kafka-source to uri)
- Wait for the Camel-K integration to start
- Provide proper file content on the FTP server instance
- Verify that the binding has performed the Kamelet source as expected by verifying the Http service sink request data

*Cleanup*
- Delete the Kamelet binding
- Delete the test Http service

## Installation

The test assumes that you have access to a Kubernetes cluster and that the Camel-K operator as well as the YAKS operator is installed
and running.

You can review the installation steps for the operators in the documentation:

- [Install Camel-K operator](https://camel.apache.org/camel-k/latest/installation/installation.html)
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
