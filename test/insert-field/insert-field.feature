Feature: Extract field Kamelet action

  Background:
    Given HTTP server timeout is 15000 ms
    Given HTTP server "test-insert-service"
    Given variables
      | field | subject |
      | value | Camel K rocks! |

  Scenario: Create Http server
    Given create Kubernetes service test-insert-service with target port 8080

  Scenario: Create Kamelet binding
    Given Camel-K resource polling configuration
      | maxAttempts          | 200   |
      | delayBetweenAttempts | 2000  |
    Given variable input is
    """
    { "id": "citrus:randomUUID()" }
    """
    When load Kubernetes custom resource insert-field-test.yaml in kameletbindings.camel.apache.org
    Then Camel-K integration insert-field-test should be running

  Scenario: Verify output message sent
    Given expect HTTP request body
    """
    { "id": "@ignore@", "${field}": "${value}" }
    """
    And HTTP request header Content-Type="application/json"
    When receive POST /result
    Then send HTTP 200 OK

  Scenario: Remove resources
    Given delete KameletBinding insert-field-test
    And delete Kubernetes service test-insert-service
