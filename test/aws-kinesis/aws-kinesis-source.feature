Feature: AWS Kinesis Kamelet

  Background:
    Given Disable auto removal of Camel resources
    Given Disable auto removal of Camel-K resources
    Given Disable auto removal of Kamelet resources

  Scenario: Create AWS Kinesis data stream
    Given variables
    | aws.kinesis.clientName | aws-kinesis-client-citrus:randomString(10, LOWERCASE) |
    | aws.kinesis.command    | "create-stream", "--stream-name", "${aws.kinesis.stream}", "--shard-count", "1" |
    When load Kubernetes resource aws-kinesis-client.yaml

  Scenario: Create Camel-K resources
    And load Camel-K integration aws-kinesis-to-log.groovy
    Then Kamelet aws-kinesis-source is available

  Scenario: Verify Kamelet source
    Given variable aws.kinesis.streamData is "Hello Kinesis"
    Given Camel exchange message header CamelAwsKinesisPartitionKey="${aws.kinesis.partitionKey}"
    Given Camel exchange body: ${aws.kinesis.streamData}
    When Camel-K integration aws-kinesis-to-log is running
    And send Camel exchange to("aws-kinesis:${aws.kinesis.stream}?accessKey=${aws.kinesis.accessKey}&secretKey=${aws.kinesis.secretKey}&region=${aws.kinesis.region}")
    Then Camel-K integration aws-kinesis-to-log should print "citrus:encodeBase64(${aws.kinesis.streamData})"

  Scenario: Remove Camel-K resources
    Given delete Camel-K integration aws-kinesis-to-log

  Scenario: Remove AWS Kinesis data stream
    Given variables
      | aws.kinesis.clientName | aws-kinesis-client-citrus:randomString(10, LOWERCASE) |
      | aws.kinesis.command    | "delete-stream", "--stream-name", "${aws.kinesis.stream}" |
    Then load Kubernetes resource aws-kinesis-client.yaml
