Feature: Telegram Kamelet - property based configuration

  Background:
    Given Disable auto removal of Camel resources
    Given Disable auto removal of Camel-K resources
    Given Disable auto removal of Kamelet resources
    Given Disable auto removal of Kubernetes resources
    Given variable message is "Hello from Kamelet source citrus:randomString(10)"

  Scenario: Create Camel-K resources
    Given Camel-K integration property file telegram-credentials.properties
    Then Kamelet telegram-source is available
    Given create Camel-K integration telegram-to-log-prop-based.groovy
    """
    from("kamelet:telegram-source/telegram-credentials")
      .to('log:info')
    """
    Given Camel-K integration telegram-to-log-prop-based is running
    Given variable loginfo is "started and consuming from: telegram"
    Then Camel-K integration telegram-to-log-prop-based should print ${loginfo}

  Scenario: Verify Kamelet source - property based configuration
    When Camel-K integration telegram-to-log-prop-based is running
    And load Kubernetes resource telegram-client.yaml
    Then Camel-K integration telegram-to-log-prop-based should print "${message}"

  Scenario: Remove Camel-K resources - property based configuration
    Given delete Camel-K integration telegram-to-log-prop-based
    Given delete Kubernetes resource telegram-client.yaml

