# FTP sink Kamelet test

This test verifies the Kamelet sink defined in [ftp-sink.kamelet.yaml](../../ftp-sink.kamelet.yaml)

## Objectives

The test verifies the FTP Kamelet sink.
The test provides an FTP server instance that the Kamelet can connect to.
The test uses a timer-source that periodically provides static file content in a Kamelet binding.
The binding uses the FTP sink to send the file and its content to the FTP server instance.
The test verifies the proper FTP file content on the server.

### Test Kamelet sink

The test performs the following high level steps:

*Preparation*
- Create and start Http test service as a sink for the Kamelet binding
- Expose the service on a given target port

*Scenario*
- Configure and create the Kamelet binding that uses the sink (kafka-sink to uri)
- Wait for the Camel K integration to start
- Verify that the binding has performed the content as expected by verifying the file content on the FTP server instance

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
