Feature: Telegram Kamelet - binding to InMemoryChannel

  Background:
    Given Disable auto removal of Camel resources
    Given Disable auto removal of Camel-K resources
    Given Disable auto removal of Kamelet resources
    Given Disable auto removal of Kubernetes resources
    Given variable message is "Hello from Kamelet source citrus:randomString(10)"
    Given create Knative channel messages

  Scenario: Verify Kamelet source - binding to InMem
    Given Kamelet telegram-source is available
    Given load KameletBinding inmem-to-log.yaml
    Given load KameletBinding telegram-to-inmem.yaml
    Given Camel-K integration telegram-to-inmem is running

    And KameletBinding inmem-to-log should be available
    Given variable loginfo2 is "started and consuming from: knative://channel/messages"
    Then Camel-K integration inmem-to-log should print ${loginfo2}
    Given variable loginfo is "started and consuming from: kamelet://telegram-source"
    Then Camel-K integration telegram-to-inmem should print ${loginfo}
    Then Camel-K integration telegram-to-inmem should print Installed features

    When Camel-K integration telegram-to-inmem is running
    And load Kubernetes resource telegram-client.yaml
    And Camel-K integration inmem-to-log should print "${message}"

    Then sleep 10000 ms

  Scenario: Remove Camel-K, Kubernetes resources
    Given delete KameletBinding telegram-to-inmem
    Given delete KameletBinding inmem-to-log
    Given delete Kubernetes resource telegram-client.yaml
