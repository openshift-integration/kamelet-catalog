Feature: AWS SQS Kamelet - binding to InMemoryChannel

  Background:
    Given Disable auto removal of Camel resources
    Given Disable auto removal of Camel-K resources
    Given Disable auto removal of Kamelet resources
    Given Disable auto removal of Kubernetes resources
    Given create Knative channel messages

  Scenario: Verify AWS-SQS Kamelet to InMemoryChannel binding
    Given Kamelet aws-sqs-source is available
    Given variables
      | aws.sqs.clientName | aws-sqs-client-citrus:randomString(10, LOWERCASE) |
      | aws.sqs.command    | "create-queue", "--queue-name", "${camel.kamelet.aws-sqs-source.aws-sqs-credentials.queueNameOrArn}" |
    When load Kubernetes resource aws-sqs-client.yaml

    Given load KameletBinding aws-sqs-to-inmem.yaml
    Given load KameletBinding inmem-to-log.yaml
    Then KameletBinding aws-sqs-to-inmem is available
    And KameletBinding inmem-to-log should be available
    Given variable loginfo is "started and consuming from: knative://channel/messages"
    Then Camel-K integration inmem-to-log should print ${loginfo}
    Given variable loginfo is "started and consuming from: kamelet://aws-sqs-source"
    Then Camel-K integration aws-sqs-to-inmem should print ${loginfo}

    And Camel-K integration aws-sqs-to-inmem should print Installed features
    And Camel-K integration inmem-to-log should print Installed features
    Then sleep 10000 ms

    Given variable aws.sqs.message is "Hello from SQS Kamelet"
    Given Camel exchange body: ${aws.sqs.message}
    And send Camel exchange to("aws2-sqs:${camel.kamelet.aws-sqs-source.aws-sqs-credentials.queueNameOrArn}?accessKey=${camel.kamelet.aws-sqs-source.aws-sqs-credentials.accessKey}&secretKey=RAW(${camel.kamelet.aws-sqs-source.aws-sqs-credentials.secretKey})&region=${camel.kamelet.aws-sqs-source.aws-sqs-credentials.region}")
    Then Camel-K integration inmem-to-log should print "${aws.sqs.message}"

  Scenario: Remove Camel-K resources
    Given delete KameletBinding aws-sqs-to-inmem
    Given delete KameletBinding inmem-to-log

  Scenario: Remove AWS SQS queue
    Given variables
      | aws.sqs.clientName | aws-sqs-client-citrus:randomString(10, LOWERCASE) |
      | aws.sqs.command    | "delete-queue", "--queue-url", "${aws.sqs.queueUrl}" |
    Then load Kubernetes resource aws-sqs-client.yaml
    Then sleep 60000 ms
