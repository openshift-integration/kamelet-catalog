Feature: Telegram Kamelet - binding to URI

  Background:
    Given Disable auto removal of Camel resources
    Given Disable auto removal of Camel K resources
    Given Disable auto removal of Kamelet resources
    Given Disable auto removal of Kubernetes resources
    Given variable message is "Hello from Kamelet source citrus:randomString(10)"

  Scenario: Create Camel K resources
    Given Kamelet telegram-source is available
    Given load KameletBinding telegram-uri-binding.yaml
    Given Camel K integration telegram-uri-binding is running
    Given variable loginfo is "Installed features"
    Then Camel K integration telegram-uri-binding should print ${loginfo}

  Scenario: Verify Kamelet source - binding to URI
    When Camel K integration telegram-uri-binding is running
    And load Kubernetes resource telegram-client.yaml
    And Camel K integration telegram-uri-binding should print "${message}"

  Scenario: Remove Camel K, Kubernetes resources
    Given delete Camel K integration telegram-uri-binding
    Given delete Kubernetes resource telegram-client.yaml
