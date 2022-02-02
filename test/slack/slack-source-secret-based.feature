Feature: Slack Kamelet - secret based configuration

  Background:
    Given Disable auto removal of Camel K resources
    Given Disable auto removal of Kamelet resources

  Scenario: Create Camel K resources
    Given create Camel K integration slack-to-log-secret-based.groovy
    """
    from("kamelet:slack-source/slack-credentials")
    .to('log:info')
    """
    Given Camel K integration slack-to-log-secret-based is running
    Given variable loginfo is "Installed features"
    Then Camel K integration slack-to-log-secret-based should print ${loginfo}

  Scenario: Verify Kamelet source - secret based configuration
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
    And Camel K integration slack-to-log-secret-based should print ${message}

  Scenario: Remove Camel K resources  - secret based configuration
    Given delete Camel K integration slack-to-log-secret-based
