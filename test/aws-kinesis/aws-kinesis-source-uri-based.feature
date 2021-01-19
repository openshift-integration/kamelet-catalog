Feature: AWS Kinesis Kamelet

  Background:
    Given Disable auto removal of Camel resources
    Given Disable auto removal of Camel-K resources
    Given Disable auto removal of Kamelet resources

  Scenario: Create AWS Kinesis data stream
    Given variables
    | aws.kinesis.clientName | aws-kinesis-client-citrus:randomString(10, LOWERCASE) |
    | aws.kinesis.command    | "create-stream", "--stream-name", "${camel.kamelet.aws-kinesis-source.aws-kinesis-credentials.stream}", "--shard-count", "1" |
    When load Kubernetes resource aws-kinesis-client.yaml

  Scenario: Create Camel-K resources - uri based config
    And load Camel-K integration aws-kinesis-to-log-uri-based.groovy
    Then Kamelet aws-kinesis-source is available

  Scenario: Verify Kamelet source - uri based config
    Given variable aws.kinesis.streamData is "Hello Kinesis"
    Given Camel exchange message header CamelAwsKinesisPartitionKey="${camel.kamelet.aws-kinesis-source.aws-kinesis-credentials.partitionKey}"
    Given Camel exchange body: ${aws.kinesis.streamData}
    When Camel-K integration aws-kinesis-to-log-uri-based is running
    And send Camel exchange to("aws-kinesis:${camel.kamelet.aws-kinesis-source.aws-kinesis-credentials.stream}?accessKey=${camel.kamelet.aws-kinesis-source.aws-kinesis-credentials.accessKey}&secretKey=RAW(${camel.kamelet.aws-kinesis-source.aws-kinesis-credentials.secretKey})&region=${camel.kamelet.aws-kinesis-source.aws-kinesis-credentials.region}")
    Then Camel-K integration aws-kinesis-to-log-uri-based should print "citrus:encodeBase64(${aws.kinesis.streamData})"

  Scenario: Remove Camel-K resources
    Given delete Camel-K integration aws-kinesis-to-log-uri-based

  Scenario: Remove AWS Kinesis data stream
    Given variables
      | aws.kinesis.clientName | aws-kinesis-client-citrus:randomString(10, LOWERCASE) |
      | aws.kinesis.command    | "delete-stream", "--stream-name", "${camel.kamelet.aws-kinesis-source.aws-kinesis-credentials.stream}" |
    Then delete Kubernetes resource aws-kinesis-client.yaml
