Feature: Jira Kamelet

  Background:
    Given Disable auto removal of Kamelet resources
    Given Disable auto removal of Camel-K resources

  Scenario: Verify resources
    Given Kamelet jira-source is available
    Given Kamelet logger-sink is available
    Given KameletBinding inmem-to-log is available
    Given Camel-K integration jira-to-inmem is running
    Given load Camel-K integration jira-to-log-secret-based.groovy
    Given load Camel-K integration jira-to-log-uri-based.groovy
    Given Camel-K integration jira-to-log-secret-based is running
    Given Camel-K integration jira-to-log-uri-based is running
    Given variable loginfo is "started and consuming from: kamelet:jira-source"
    Then Camel-K integration jira-to-log-secret-based should print ${loginfo}
    Then Camel-K integration jira-to-log-uri-based should print ${loginfo}

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
    Then receive HTTP 201 CREATED
    And Camel-K integration jira-to-log-secret-based should print ${summary}
    And Camel-K integration jira-to-log-uri-based should print ${summary}
    And Camel-K integration inmem-to-log should print ${summary}

  Scenario: Remove Camel-K resources
    Given delete Camel-K integration jira-to-log-secret-based
    Given delete Camel-K integration jira-to-log-uri-based
    Given delete Camel-K integration jira-to-inmem
    Given delete Camel-K integration inmem-to-log
    Given delete KameletBinding inmem-to-log
