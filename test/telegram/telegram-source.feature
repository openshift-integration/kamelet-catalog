Feature: Telegram Kamelet

  Background:
    Given Disable auto removal of Camel resources
    Given Disable auto removal of Camel-K resources
    Given Disable auto removal of Kamelet resources

  Scenario: Create Camel-K resources
    When load Kamelet telegram-source.kamelet.yaml
    And load Camel-K integration telegram-to-log.groovy
    Then Kamelet telegram-source is available

  Scenario: Verify Kamelet source
    Given variable message is "Hello from Kamelet source citrus:randomString(10)"
    When Camel-K integration telegram-to-log is running
    And load Kubernetes resource telegram-client.yaml
    Then Camel-K integration telegram-to-log should print "${message}"

  Scenario: Remove Camel-K resources
    Given delete Camel-K integration telegram-to-log
