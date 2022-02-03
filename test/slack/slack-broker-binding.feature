Feature: Slack Kamelet

  Background:
    Given Disable auto removal of Camel K resources
    Given Disable auto removal of Kamelet resources
    Given create Knative broker default
    Then Knative broker default is running

  Scenario: Verify Slack Kamelet to broker binding
    Given Kamelet slack-source is available
    Given load KameletBinding broker-to-log.yaml
    Given load KameletBinding slack-to-broker.yaml

    Then KameletBinding slack-to-broker should be available
    And Camel K integration slack-to-broker should print kamelet://slack-source/source
    And KameletBinding broker-to-log should be available
    Given variable loginfo is "knative://event/custom-type"
    Then Camel K integration broker-to-log should print ${loginfo}

    #Avoid sending message too early
    And Camel K integration slack-to-broker should print Installed features
    And Camel K integration broker-to-log should print Installed features
    Then sleep 10000 ms

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
    And Camel K integration broker-to-log should print ${message}

  Scenario: Remove Camel K resources
    Given delete KameletBinding broker-to-log
    Given delete KameletBinding slack-to-broker
