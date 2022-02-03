Feature: AWS Kinesis Kamelet

  Background:
    Given Disable auto removal of Camel resources
    Given Disable auto removal of Camel K resources
    Given Disable auto removal of Kamelet resources
    Given Disable auto removal of Kubernetes resources

  Scenario: Create AWS Kinesis data stream
    Given variables
    | aws.kinesis.clientName | aws-kinesis-client-citrus:randomString(10, LOWERCASE) |
    | aws.kinesis.command    | "create-stream", "--stream-name", "${camel.kamelet.aws-kinesis-source.aws-kinesis-credentials.stream}", "--shard-count", "1" |
    When load Kubernetes resource aws-kinesis-client.yaml

  Scenario: Create Camel K resources - property based config
    Given Camel K integration property file aws-kinesis-credentials.properties
    Given create Camel K integration aws-kinesis-to-log-prop-based.groovy
    """
    from("kamelet:aws-kinesis-source/aws-kinesis-credentials")
    .to('log:info')
    """
    Then Kamelet aws-kinesis-source is available

  Scenario: Verify Kamelet source - property based config
    Given variable aws.kinesis.streamData is "abc"
    Given Camel exchange message header CamelAwsKinesisPartitionKey="${camel.kamelet.aws-kinesis-source.aws-kinesis-credentials.partitionKey}"
    Given Camel exchange body: ${aws.kinesis.streamData}
    When Camel K integration aws-kinesis-to-log-prop-based is running
    Then sleep 10000 ms
    And send Camel exchange to("aws2-kinesis:${camel.kamelet.aws-kinesis-source.aws-kinesis-credentials.stream}?accessKey=${camel.kamelet.aws-kinesis-source.aws-kinesis-credentials.accessKey}&secretKey=RAW(${camel.kamelet.aws-kinesis-source.aws-kinesis-credentials.secretKey})&region=${camel.kamelet.aws-kinesis-source.aws-kinesis-credentials.region}")
    Then Camel K integration aws-kinesis-to-log-prop-based should print "data":{"bytes":[97,98,99]

  Scenario: Remove Camel K resources
    Given delete Camel K integration aws-kinesis-to-log-prop-based

  Scenario: Remove AWS Kinesis data stream
    Given variables
      | aws.kinesis.clientName | aws-kinesis-client-citrus:randomString(10, LOWERCASE) |
      | aws.kinesis.command    | "delete-stream", "--stream-name", "${camel.kamelet.aws-kinesis-source.aws-kinesis-credentials.stream}" |
    Then load Kubernetes resource aws-kinesis-client.yaml
