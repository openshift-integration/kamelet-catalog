Feature: Jira Kamelet - binding to URI

  Background:
    Given Disable auto removal of Kamelet resources
    Given Disable auto removal of Camel-K resources
    Given Kamelet jira-source is available

  Scenario: Verify resources
    Given load KameletBinding jira-uri-binding.yaml
    Given KameletBinding jira-uri-binding is available
    Given variable loginfo is "started and consuming from: kamelet://jira-source"
    Then Camel-K integration jira-uri-binding should print ${loginfo}

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
    And Camel-K integration jira-uri-binding should print ${summary}
    Given URL: ${camel.kamelet.jira-source.jira-credentials.jiraUrl}
    And HTTP request header Authorization="Basic citrus:encodeBase64(${camel.kamelet.jira-source.jira-credentials.username}:${camel.kamelet.jira-source.jira-credentials.password})"
    And HTTP request header Content-Type="application/json"
    When send DELETE /rest/api/2/issue/${key}
    Then receive HTTP 204 NO_CONTENT

  Scenario: Remove Camel-K resources
    Given delete Camel-K integration jira-uri-binding
