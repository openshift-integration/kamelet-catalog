# Kafka Kamelet source/sink test

This test verifies the Kamelet source defined in [kafka-source.kamelet.yaml](../../kafka-source.kamelet.yaml) 
and the Kamelet sink defined in [kafka-sink.kamelet.yaml](../../kafka-sink.kamelet.yaml)

## Objectives

The test verifies the Kafka Kamelet source/sink by creating Kamelet bindings that use the source/sink to consume/produce 
messages on a Kafka topic.
The test itself produces/consumes messages on the topic to verify the Kamelet bindings and its source/sink.

### Test Kamelet source

The Kafka Kamelet source binds topic messages to a test Http service in order to verify the sink outcome of the binding.

The test performs the following high level steps:

*Preparation*
- Create and start Http test service as a sink for the Kamelet binding
- Expose the service on a given target port

*Scenario* 
- Configure and create the Kamelet binding that uses the source (kafka-source to uri)
- Wait for the Camel-K integration to start
- Send message to Kafka topic
- Verify that the source binding has processed the Kafka message as expected by verifying the Http service sink request data

*Cleanup*
- Delete the Kamelet binding
- Delete the test Http service

### Test Kamelet source

The Kafka Kamelet sink test uses a timer-source to periodically send Kafka messages to a topic.
The test consumes the messages and verifies the message content.

The test performs the following high level steps:

*Preparation*
- Connect to Kafka bootstrap servers

*Scenario* 
- Configure and create the Kamelet binding that uses the sink (timer-source to kafka)
- Wait for the Camel-K integration to start
- Receive and verify message on Kafka topic

*Cleanup*
- Delete the Kamelet binding

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
$ yaks run test/kafka/kafka-source.feature
$ yaks run test/kafka/kafka-sink.feature
```

You will be provided with the test log output and the test results.
