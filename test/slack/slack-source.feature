Feature: Slack Kamelet

  Background:
    Given Disable auto removal of Camel-K resources
    Given Disable auto removal of Kamelet resources

  Scenario: Create Camel-K resources
    And load Camel-K integration slack-to-log.groovy

  Scenario: Verify Kamelet source
    Given variable message is "Hello from Kamelet source citrus:randomString(10)"
    Given Camel-K integration slack-to-log is running
    Given URL: https://slack.com
    And HTTP request header Authorization="Bearer ${slack.token}"
    And HTTP request header Content-Type="application/json"
    And HTTP request body
    """
    {
      "channel": "${slack.channel}",
      "text":"${message}"
    }
    """
    When send POST /api/chat.postMessage
    Then receive HTTP 200 OK
    And Camel-K integration slack-to-log should print "${message}"

  Scenario: Remove Camel-K resources
    Given delete Camel-K integration slack-to-log
