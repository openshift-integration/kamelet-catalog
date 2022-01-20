Feature: Kafka Kamelet source

  Background:
    Given variable user is ""
    Given variable password is ""
    Given variables
      | bootstrap.server.host     | my-cluster-kafka-bootstrap |
      | bootstrap.server.port     | 9092 |
      | securityProtocol          | PLAINTEXT |
      | deserializeHeaders        | true |
      | topic                     | my-topic |
      | source                    | Kafka Kamelet source |
      | message                   | Camel K rocks! |
    Given Kafka topic: ${topic}
    Given Kafka topic partition: 0
    Given HTTP server timeout is 15000 ms
    Given HTTP server "kafka-to-http-service"

  Scenario: Create Http server
    Given create Kubernetes service kafka-to-http-service with target port 8080

  Scenario: Create Kamelet binding
    Given Camel-K resource polling configuration
      | maxAttempts          | 200   |
      | delayBetweenAttempts | 2000  |
    When load KameletBinding kafka-source-test.yaml
    Then Camel-K integration kafka-source-test should be running
    And Camel-K integration kafka-source-test should print Resetting offset for partition ${topic}-0

  Scenario: Send message to Kafka topic and verify sink output
    Given Kafka connection
      | url         | ${bootstrap.server.host}.${YAKS_NAMESPACE}:${bootstrap.server.port} |
    When send Kafka message with body and headers: ${message}
      | event-source | ${source} |
    Then expect HTTP request body: ${message}
    Then expect HTTP request header: event-source="${source}"
    And receive POST /result
    And send HTTP 200 OK

  Scenario: Remove resources
    Given delete KameletBinding kafka-source-test
    And delete Kubernetes service kafka-to-http-service
