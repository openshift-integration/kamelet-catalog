Feature: AWS-Kinesis Kamelet

  Background:
    Given Disable auto removal of Camel resources
    Given Disable auto removal of Camel-K resources
    Given Disable auto removal of Kamelet resources
    Given Disable auto removal of Kubernetes resources

  Scenario: Verify AWS-Kinesis Kamelet to InMemoryChannel binding
    Given Kamelet aws-kinesis-source is available
    Given create Knative channel messages
    Given variables
      | aws.kinesis.clientName | aws-kinesis-client-citrus:randomString(10, LOWERCASE) |
      | aws.kinesis.command    | "create-stream", "--stream-name", "${camel.kamelet.aws-kinesis-source.aws-kinesis-credentials.stream}", "--shard-count", "1" |
    When load Kubernetes resource aws-kinesis-client.yaml

    Given load KameletBinding aws-kinesis-to-inmem.yaml
    Then KameletBinding aws-kinesis-to-inmem should be available
    Given load KameletBinding inmem-to-log.yaml
    And KameletBinding inmem-to-log should be available
    And Camel-K integration aws-kinesis-to-inmem is running
    And Camel-K integration inmem-to-log is running

    And Camel-K integration aws-kinesis-to-inmem should print Installed features
    And Camel-K integration inmem-to-log should print Installed features
    Then sleep 10000 ms

    Given variable aws.kinesis.streamData is "Hello Kinesis"
    Given Camel exchange message header CamelAwsKinesisPartitionKey="${camel.kamelet.aws-kinesis-source.aws-kinesis-credentials.partitionKey}"
    Given Camel exchange body: ${aws.kinesis.streamData}
    When Camel-K integration aws-kinesis-to-inmem is running
    And send Camel exchange to("aws2-kinesis:${camel.kamelet.aws-kinesis-source.aws-kinesis-credentials.stream}?accessKey=${camel.kamelet.aws-kinesis-source.aws-kinesis-credentials.accessKey}&secretKey=RAW(${camel.kamelet.aws-kinesis-source.aws-kinesis-credentials.secretKey})&region=${camel.kamelet.aws-kinesis-source.aws-kinesis-credentials.region}")
    Then Camel-K integration inmem-to-log should print ${aws.kinesis.streamData}

  Scenario: Remove Camel-K resources
    Given variables
      | aws.kinesis.clientName | aws-kinesis-client-citrus:randomString(10, LOWERCASE) |
      | aws.kinesis.command    | "delete-stream", "--stream-name", "${camel.kamelet.aws-kinesis-source.aws-kinesis-credentials.stream}" |
    Then load Kubernetes resource aws-kinesis-client.yaml
    Given delete KameletBinding inmem-to-log
    Given delete KameletBinding aws-kinesis-to-inmem
