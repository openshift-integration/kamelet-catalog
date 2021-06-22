Feature: AWS SQS Kamelet - binding to URI

  Background:
    Given Disable auto removal of Camel resources
    Given Disable auto removal of Camel-K resources
    Given Disable auto removal of Kamelet resources
    Given Disable auto removal of Kubernetes resources

  Scenario: Create AWS SQS queue
    Given variables
    | aws.sqs.clientName | aws-sqs-client-citrus:randomString(10, LOWERCASE) |
    | aws.sqs.command    | "create-queue", "--queue-name", "${camel.kamelet.aws-sqs-source.aws-sqs-credentials.queueNameOrArn}" |
    When load Kubernetes resource aws-sqs-client.yaml

  Scenario: Create Camel-K resources
    Given Kamelet aws-sqs-source is available
    Given load KameletBinding aws-sqs-uri-binding.yaml
    Given KameletBinding aws-sqs-uri-binding is available
    Given variable loginfo is "Installed features"
    Then Camel-K integration aws-sqs-uri-binding should print ${loginfo}

  Scenario: Verify Kamelet source
    Given variable aws.sqs.message is "Hello from SQS Kamelet"
    Given Camel exchange body: ${aws.sqs.message}
    When Camel-K integration aws-sqs-uri-binding is running
    And send Camel exchange to("aws2-sqs:${camel.kamelet.aws-sqs-source.aws-sqs-credentials.queueNameOrArn}?accessKey=${camel.kamelet.aws-sqs-source.aws-sqs-credentials.accessKey}&secretKey=RAW(${camel.kamelet.aws-sqs-source.aws-sqs-credentials.secretKey})&region=${camel.kamelet.aws-sqs-source.aws-sqs-credentials.region}")
    Then Camel-K integration aws-sqs-uri-binding should print "${aws.sqs.message}"

  Scenario: Remove Camel-K resources
    Given delete KameletBinding aws-sqs-uri-binding
    Given delete Camel-K integration aws-sqs-uri-binding

  Scenario: Remove AWS SQS queue
    Given variables
      | aws.sqs.clientName | aws-sqs-client-citrus:randomString(10, LOWERCASE) |
      | aws.sqs.command    | "delete-queue", "--queue-url", "${aws.sqs.queueUrl}" |
    Then load Kubernetes resource aws-sqs-client.yaml
    Then sleep 60000 ms
