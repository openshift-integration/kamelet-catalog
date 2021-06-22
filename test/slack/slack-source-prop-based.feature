Feature: Slack Kamelet - property based configuration

  Background:
    Given Disable auto removal of Camel-K resources
    Given Disable auto removal of Kamelet resources

  Scenario: Create Camel-K resources
    Given Camel-K integration property file slack-credentials.properties
    Given create Camel-K integration slack-to-log-prop-based.groovy
    """
    from("kamelet:slack-source/slack-credentials")
    .to('log:info')
    """
    Given Camel-K integration slack-to-log-prop-based is running
    Given variable loginfo is "Installed features"
    Then Camel-K integration slack-to-log-prop-based should print ${loginfo}

  Scenario: Verify Kamelet source - property based configuration
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
    And Camel-K integration slack-to-log-prop-based should print ${message}

  Scenario: Remove Camel-K resources - property based configuration
    Given delete Camel-K integration slack-to-log-prop-based


