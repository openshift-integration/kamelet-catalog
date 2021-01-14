Feature: Slack Kamelet

  Background:
    Given Disable auto removal of Camel-K resources
    Given Disable auto removal of Kamelet resources

  Scenario: Create Camel-K resources
    Given load Camel-K integration slack-to-log-uri-based.groovy
    Given create Camel-K integration slack-to-log-secret-based.groovy
    """
    from("kamelet:slack-source/slack-credentials")
    .to('log:info')
    """
    Given Camel-K integration slack-to-log-secret-based is running
    Given Camel-K integration slack-to-log-uri-based is running
    Given variable loginfo is "started and consuming from: slack"
    Then Camel-K integration slack-to-log-uri-based should print ${loginfo}
    Then Camel-K integration slack-to-log-secret-based should print ${loginfo}

  Scenario: Verify Kamelet source
    Given variable message is "Hello from Kamelet source citrus:randomString(10)"
    Given Camel-K integration slack-to-log-uri-based is running
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
    And Camel-K integration slack-to-log-uri-based should print ${message}
    And Camel-K integration slack-to-log-secret-based should print ${message}

  Scenario: Remove Camel-K resources
    Given delete Camel-K integration slack-to-log-uri-based
    Given delete Camel-K integration slack-to-log-secret-based
