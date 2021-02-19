Feature: Slack Kamelet

  Background:
    Given Disable auto removal of Camel-K resources
    Given Disable auto removal of Kamelet resources
    Given create Knative channel messages

  Scenario: Verify Slack Kamelet to InMemoryChannel binding
    Given Kamelet slack-source is available
    Given load KameletBinding inmem-to-log.yaml
    Given load KameletBinding slack-to-inmem.yaml
    Then KameletBinding slack-to-inmem should be available
    And KameletBinding inmem-to-log should be available
    Given variable loginfo is "started and consuming from: knative://channel/messages"
    Then Camel-K integration inmem-to-log should print ${loginfo}

    Given variable message is "Hello from Kamelet source citrus:randomString(10)"
    Given URL: https://slack.com
    And HTTP request header Authorization="Bearer ${camel.kamelet.slack-source.slack-credentials.token}"
    And HTTP request header Content-Type="application/json"
    And HTTP request body
    """
    {
      "channel": "${camel.kamelet.slack-source.slack-credentials.channel}",
      "text":"${message}"
    }
    """
    When send POST /api/chat.postMessage
    Then receive HTTP 200 OK
    And Camel-K integration inmem-to-log should print ${message}

  Scenario: Remove Camel-K resources
    Given delete KameletBinding inmem-to-log
    Given delete KameletBinding slack-to-inmem
    #NOTE: InMemoryChannel is autoremoved