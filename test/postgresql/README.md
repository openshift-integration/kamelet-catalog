# PostgreSQL Kamelet sink test

This test verifies the Kamelet sink defined in [postgresql-sink.kamelet.yaml](../../postgresql-sink.kamelet.yaml)

## Objectives

The test verifies the PostgreSQL Kamelet sink by creating Kamelet bindings that use the sink to insert 
data on a PostgreSQL database.

The test itself queries and validates the inserted data on the database in order to verify the Kamelet bindings and its sink.

### Test Kamelet sink

The PostgreSQL Kamelet sink binds events to a database table as the sink outcome of a Kamelet binding.
The test uses a timer-source in combination with the PostgreSQL Kamelet sink to periodically insert data into the database.

The test performs the following high level steps:

*Preparation*
- Create and start PostgreSQL database container
- Expose the database service on a given target port

*Scenario* 
- Configure and create the Kamelet binding that uses the sink (timer to postgresql sink)
- Wait for the Camel-K integration to start
- Query the PostgreSQL database and verify the result set

*Cleanup*
- Delete the Kamelet binding
- Delete the PostgreSQL database

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
$ yaks run test/postgresql/postgresql-sink.feature
```

You will be provided with the test log output and the test results.
