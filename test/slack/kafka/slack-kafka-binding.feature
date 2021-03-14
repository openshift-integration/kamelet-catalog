Feature: Slack Kamelet

  Background:
    Given Disable auto removal of Camel-K resources
    Given Disable auto removal of Kamelet resources

  Scenario: Verify Slack Kamelet to Kafka binding
    Given Kamelet slack-source is available

    Given Kafka connection
      | url           | my-cluster-kafka-bootstrap:9092 |
      | topic         | my-topic       |
    Given Kafka producer configuration
      | client.id          | producer-1 |
      | request.timeout.ms | 5000 |

    Given Kafka consumer configuration
      | client.id          | kafka-consumer |
      | max.poll.records   | 1 |

    Given Kafka topic: my-topic
    Given load KameletBinding slack-to-kafka.yaml
    Then KameletBinding slack-to-kafka should be available
    Given variable printInfo is "source started and consuming from: slack"
    And Camel-K integration slack-to-kafka should print ${printInfo}

    #send message
    Given variable message is "Slack-to-Kafka Kameletbinding test citrus:randomString(10)"
    Given URL: https://slack.com
    And HTTP request header Authorization="Bearer ${camel.kamelet.slack-source.slack-credentials.token}"
    And HTTP request header Content-Type="application/json"
    And HTTP request body
    """
    {
      "channel": "testchannel",
      "text":"${message}"
    }
    """
    When send POST /api/chat.postMessage
    Then verify HTTP response expression: $.ts="@variable(ts)@"
    And verify HTTP response expression: $.channel="@variable(testchannelid)@"
    Then receive HTTP 200 OK

    #check message
    Then receive Kafka message with body
    """
    {"text":"${message}","channel":null,"username":null,"user":null,"iconUrl":null,"iconEmoji":null,"attachments":null}
    """

    #delete message
    Given URL: https://slack.com
    And HTTP request header Authorization="Bearer ${camel.kamelet.slack-source.slack-credentials.token}"
    And HTTP request header Content-Type="application/json"
    And HTTP request body
    """
    {
      "channel": "${testchannelid}",
      "ts":"${ts}"
    }
    """
    When send POST /api/chat.delete
    Then receive HTTP 200 OK

  Scenario: Remove Camel-K resources
    Given delete KameletBinding slack-to-kafka
    