Feature: Telegram Kamelet - secret based configuration

  Background:
    Given Disable auto removal of Camel resources
    Given Disable auto removal of Camel K resources
    Given Disable auto removal of Kamelet resources
    Given Disable auto removal of Kubernetes resources
    Given variable message is "Hello from Kamelet source citrus:randomString(10)"

  Scenario: Create Camel K resources
    Given Kamelet telegram-source is available
    Given create Camel K integration telegram-to-log-secret-based.groovy
    """
    from("kamelet:telegram-source/telegram-credentials")
    .to('log:info')
    """
    Given Camel K integration telegram-to-log-secret-based is running
    Given variable loginfo is "Installed features"
    Then Camel K integration telegram-to-log-secret-based should print ${loginfo}

  Scenario: Verify Kamelet source - secret based configuration
    When Camel K integration telegram-to-log-secret-based is running
    And load Kubernetes resource telegram-client.yaml
    And Camel K integration telegram-to-log-secret-based should print "${message}"

  Scenario: Remove Camel K, Kubernetes resources - secret based configuration
    Given delete Camel K integration telegram-to-log-secret-based
    Given delete Kubernetes resource telegram-client.yaml
