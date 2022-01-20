Feature: Kafka Kamelet sink

  Background:
    Given variable user is ""
    Given variable password is ""
    Given variables
      | bootstrap.server.host     | my-cluster-kafka-bootstrap |
      | bootstrap.server.port     | 9092 |
      | securityProtocol          | PLAINTEXT |
      | topic                     | my-topic |
      | message                   | Camel K rocks! |
    Given Kafka topic: ${topic}
    Given Kafka topic partition: 0

  Scenario: Create Kamelet binding
    Given Camel-K resource polling configuration
      | maxAttempts          | 200   |
      | delayBetweenAttempts | 2000  |
    When load KameletBinding kafka-sink-test.yaml
    Then Camel-K integration kafka-sink-test should be running

  Scenario: Receive message on Kafka topic and verify sink output
    Given Kafka connection
      | url         | ${bootstrap.server.host}.${YAKS_NAMESPACE}:${bootstrap.server.port} |
    Then receive Kafka message with body: ${message}

  Scenario: Remove resources
    Given delete KameletBinding kafka-sink-test
