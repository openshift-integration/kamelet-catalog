Feature: Extract field Kamelet action

  Background:
    Given HTTP server timeout is 15000 ms
    Given HTTP server "test-extract-service"

  Scenario: Create Http server
    Given create Kubernetes service test-extract-service with target port 8080

  Scenario: Create Kamelet binding
    Given Camel K resource polling configuration
      | maxAttempts          | 200   |
      | delayBetweenAttempts | 2000  |
    Given variable field = "subject"
    Given variable input is
    """
    { "id": "citrus:randomUUID()", "subject": "Camel K rocks!" }
    """
    When load Kubernetes custom resource extract-field-test.yaml in kameletbindings.camel.apache.org
    Then Camel K integration extract-field-test should be running

  Scenario: Verify output message sent
    Given expect HTTP request body: "Camel K rocks!"
    When receive POST /result
    Then send HTTP 200 OK

  Scenario: Remove resources
    Given delete KameletBinding extract-field-test
    And delete Kubernetes service test-extract-service
