Feature: Slack Kamelet - URI based configuration

  Background:
    Given Disable auto removal of Camel-K resources
    Given Disable auto removal of Kamelet resources

  Scenario: Create Camel-K resources
    Given load Camel-K integration slack-to-log-uri-based.groovy
    Given Camel-K integration slack-to-log-uri-based is running
    Given variable loginfo is "Installed features"
    Then Camel-K integration slack-to-log-uri-based should print ${loginfo}

  Scenario: Verify Kamelet source - URI based configuration
    Given variable message is "Hello from Kamelet source citrus:randomString(10)"
    Given URL: https://slack.com
    And HTTP request header Authorization="Bearer ${camel.kamelet.slack-source.slack-credentials.token}"
    And HTTP request header Content-Type="application/json"
    And HTTP request body
    """
    {
      "channel": "general",
      "text":"${message}"
    }
    """
    When send POST /api/chat.postMessage
    Then receive HTTP 200 OK
    And Camel-K integration slack-to-log-uri-based should print ${message}

  Scenario: Remove Camel-K resources - URI based configuration
    Given delete Camel-K integration slack-to-log-uri-based
