Feature: Salesforce Kamelet binding

  Background:
    Given Disable auto removal of Camel-K resources
    Given Disable auto removal of Kamelet resources
    Given Disable auto removal of Kubernetes resources
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

  Scenario: Create KameletBinding
    Given variable query is "SELECT Id, Subject FROM Case"
    And variable topicName is "CamelTestTopic"
    And load KameletBinding salesforce-to-uri.yaml
    Then Kamelet salesforce-source is available
    And KameletBinding salesforce-to-uri is available

  Scenario: Create Http service
    Given HTTP server "salesforce-case-service"
    Given HTTP server timeout is 15000 ms
    Given create Kubernetes service salesforce-case-service with target port 8080

  Scenario: Verify Kamelet binding
    Given variable subject is "Case regarding citrus:randomString(10)"
    Given variable description is "Test for Salesforce Kamelet source"
    Given Camel-K integration salesforce-to-uri is running
    And Camel-K integration salesforce-to-uri should print Login successful
    And Camel-K integration salesforce-to-uri should print Subscribed to channel /topic/CamelTestTopic
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
    And expect HTTP request body
    """
    {
      "Id": "@ignore@",
      "Subject": "${subject}"
    }
    """
    And receive POST /case

  Scenario: Remove KameletBinding
    Given delete KameletBinding salesforce-to-uri
    And delete Kubernetes service salesforce-case-service
