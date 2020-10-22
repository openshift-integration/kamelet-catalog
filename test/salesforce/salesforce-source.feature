Feature: Salesforce Kamelet

  Background:
    Given Disable auto removal of Camel-K resources
    Given Disable auto removal of Kamelet resources
    Given variable token_request is "grant_type=password&client_id=${salesforce.clientId}&client_secret=${salesforce.clientSecret}&username=${salesforce.userName}&password=${salesforce.password}"
    Given URL: ${salesforce.loginUrl}
    And HTTP request header Content-Type="application/x-www-form-urlencoded"
    And HTTP request body: ${token_request}
    When send POST /services/oauth2/token
    Then verify HTTP response expression: $.instance_url="@variable(instance_url)@"
    And verify HTTP response expression: $.access_token="@variable(access_token)@"
    And receive HTTP 200 OK
    Given URL: ${instance_url}
    And HTTP request header Authorization="Bearer ${access_token}"
    And HTTP request header Content-Type="application/json"
    And HTTP request query parameter q="citrus:urlEncode('SELECT Id,Name FROM Account LIMIT 1')"
    When send GET /services/data/v${salesforce.apiVersion}/query/
    Then verify HTTP response expression: $.records[0].Id="@variable(account_id)@"
    And receive HTTP 200 OK

  Scenario: Create Camel-K resources
    Given variable query is "SELECT Id, Subject FROM Case"
    And variable topicName is "CamelTestTopic"
    When load Kamelet salesforce-source.kamelet.yaml
    And load Camel-K integration salesforce-to-log.groovy
    Then Kamelet salesforce-source is available
    And Camel-K integration salesforce-to-log is running
    And Camel-K integration salesforce-to-log should print Login successful
    And Camel-K integration salesforce-to-log should print Subscribed to channel /topic/CamelTestTopic

  Scenario: Create Case object
    Given variable subject is "Case regarding citrus:randomString(10)"
    Given variable description is "Test for Salesforce Kamelet source"
    And HTTP request header Authorization="Bearer ${access_token}"
    And HTTP request header Content-Type="application/json"
    And HTTP request body
    """
    {
      "Subject": "${subject}",
      "AccountId": "${account_id}",
      "Description" : "${description}"
    }
    """
    When send POST /services/data/v${salesforce.apiVersion}/sobjects/Case
    Then receive HTTP 201 Created
    And Camel-K integration salesforce-to-log should print "Subject":"${subject}"

  Scenario: Remove Camel-K resources
    Given delete Camel-K integration salesforce-to-log
