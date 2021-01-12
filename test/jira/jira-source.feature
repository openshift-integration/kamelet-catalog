Feature: Jira Kamelet

  Background:
    Given Disable auto removal of Kamelet resources

  Scenario: Verify resources
    Given Kamelet jira-source is available
    Given Kamelet logger-sink is available
    Given KameletBinding inmem-to-log is available
    Given Camel-K integration jira-to-inmem is running

  Scenario: Verify new jira issue is created
    Given variable summary is "New bug, citrus:randomString(10)"
    Given URL: ${camel.kamelet.jira-source.jiraUrl}
    And HTTP request header Authorization="Basic citrus:encodeBase64(${camel.kamelet.jira-source.username}:${camel.kamelet.jira-source.password})"
    And HTTP request header Content-Type="application/json"
    And HTTP request body
    """
    {
         "fields": {
               "project":
               {
                  "key": "citrus:substring(${camel.kamelet.jira-source.jql}, 8)"
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
    Then receive HTTP 201 CREATED
    Then Camel-K integration inmem-to-log should print "${summary}"
