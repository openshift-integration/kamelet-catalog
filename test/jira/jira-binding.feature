Feature: Jira Kamelet Binding

  Background:
    Given Disable auto removal of Kamelet resources
    Given Disable auto removal of Camel-K resources
    Given Disable auto removal of Kubernetes resources

  Scenario: Verify resources
    Given Kamelet logger-sink is available
    Given load KameletBinding jira-to-inmem.yaml
    Given load KameletBinding inmem-to-log.yaml
    Given KameletBinding jira-to-inmem is available
    Given KameletBinding inmem-to-log is available
    Given variable loginfo is "knative://channel/messages"
    Then Camel-K integration inmem-to-log should print ${loginfo}

  Scenario: Verify new jira issue is created
    Given variable summary is "New bug, citrus:randomString(10)"
    Given URL: ${camel.kamelet.jira-source.jira-credentials.jiraUrl}
    And HTTP request header Authorization="Basic citrus:encodeBase64(${camel.kamelet.jira-source.jira-credentials.username}:${camel.kamelet.jira-source.jira-credentials.password})"
    And HTTP request header Content-Type="application/json"
    And HTTP request body
    """
    {
         "fields": {
               "project":
               {
                  "key": "citrus:substring(${camel.kamelet.jira-source.jira-credentials.jql}, 8)"
               },
               "summary": "${summary}",
               "description": "Yaks test of jira-source kamelet",
               "issuetype": {
                  "id": "1"
               }
           }
    }
    """
    When send POST /rest/api/2/issue/
    Then verify HTTP response expression: $.key="@variable(key)@"
    Then receive HTTP 201 CREATED
    And Camel-K integration inmem-to-log should print ${summary}
    Given URL: ${camel.kamelet.jira-source.jira-credentials.jiraUrl}
    And HTTP request header Authorization="Basic citrus:encodeBase64(${camel.kamelet.jira-source.jira-credentials.username}:${camel.kamelet.jira-source.jira-credentials.password})"
    And HTTP request header Content-Type="application/json"
    When send DELETE /rest/api/2/issue/${key}
    Then receive HTTP 204 NO_CONTENT

  Scenario: Remove Camel-K resources
    Given delete Camel-K integration jira-to-inmem
    Given delete Camel-K integration inmem-to-log
    Given delete KameletBinding jira-to-inmem
    Given delete KameletBinding inmem-to-log
