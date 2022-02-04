# FTP Kamelet source/sink test

This test verifies the Kamelet source defined in [ftp-source.kamelet.yaml](../../ftp-source.kamelet.yaml) 
and the Kamelet sink defined in [ftp-sink.kamelet.yaml](../../ftp-sink.kamelet.yaml)

## Objectives

The test verifies the FTP Kamelet source/sink by creating Kamelet bindings that use the source/sink to consume/produce 
files on a FTP server.
The test itself provides a FTP server instance that can be used by the Kamelet source/sink.

- [FTP Kamelet source test](source/README.md)
- [FTP Kamelet sink test](sink/README.md)

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
$ yaks run test/ftp/source/ftp-source.feature
$ yaks run test/ftp/sink/ftp-sink.feature
```

You will be provided with the test log output and the test results.
