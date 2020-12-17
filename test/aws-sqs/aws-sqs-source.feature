Feature: AWS SQS Kamelet

  Background:
    Given Disable auto removal of Camel resources
    Given Disable auto removal of Camel-K resources
    Given Disable auto removal of Kamelet resources

  Scenario: Create Camel-K resources
    Given create Camel-K integration sqs-to-log.groovy
    """
    from('kamelet:aws-sqs-source?queueNameOrArn=${aws-sqs.queueNameOrArn}&accessKey=${aws-sqs.accessKey}&secretKey=RAW(${aws-sqs.secretKey})&region=${aws-sqs.region}&deleteAfterRead=${aws-sqs.deleteAfterRead}')
        .to("log:info")
    """

  Scenario: Verify Kamelet source
    Given variable message is "Hello from Kamelet source citrus:randomString(10)"
    When Camel-K integration sqs-to-log is running
    And load Kubernetes resource aws-sqs-client.yaml
    Then Camel-K integration sqs-to-log should print "${message}"

  Scenario: Remove Camel-K resources
    Given delete Camel-K integration sqs-to-log
