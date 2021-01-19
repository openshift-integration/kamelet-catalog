Feature: Telegram Kamelet - URI based config

  Background:
    Given Disable auto removal of Camel resources
    Given Disable auto removal of Camel-K resources
    Given Disable auto removal of Kamelet resources
    Given Disable auto removal of Kubernetes resources
    Given variable message is "Hello from Kamelet source citrus:randomString(10)"

  Scenario: Create Camel-K resources
    When load Camel-K integration telegram-to-log-uri-based.groovy
    Then Kamelet telegram-source is available
    Given Camel-K integration telegram-to-log-uri-based is running
    Given variable loginfo is "started and consuming from: telegram"
    Then Camel-K integration telegram-to-log-uri-based should print ${loginfo}

  Scenario: Verify Kamelet source - URI based config
    When Camel-K integration telegram-to-log-uri-based is running
    And load Kubernetes resource telegram-client.yaml
    Then Camel-K integration telegram-to-log-uri-based should print "${message}"

  Scenario: Remove Camel-K resources - URI based config
    Given delete Camel-K integration telegram-to-log-uri-based
    Given delete Kubernetes resource telegram-client.yaml
