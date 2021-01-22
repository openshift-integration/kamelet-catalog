Feature: Salesforce Kamelet

  Background:
    Given Disable auto removal of Camel-K resources
    Given Disable auto removal of Kamelet resources
    Given variable token_request is "grant_type=password&client_id=${camel.kamelet.salesforce-source.salesforce-credentials.clientId}&client_secret=${camel.kamelet.salesforce-source.salesforce-credentials.clientSecret}&username=${camel.kamelet.salesforce-source.salesforce-credentials.userName}&password=${camel.kamelet.salesforce-source.salesforce-credentials.password}"
    Given URL: ${camel.kamelet.salesforce-source.salesforce-credentials.loginUrl}
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
    When send GET /services/data/v${camel.kamelet.salesforce-source.salesforce-credentials.apiVersion}/query/
    Then verify HTTP response expression: $.records[0].Id="@variable(account_id)@"
    And receive HTTP 200 OK

  Scenario: Create Camel-K resources
    Given Camel-K integration property file salesforce-credentials.properties
    Given create Camel-K integration salesforce-to-log-property-based.groovy
    """
    from("kamelet:salesforce-source/salesforce-credentials")
    .to('log:info')
    """
    Then Kamelet salesforce-source is available

  Scenario: Verify Kamelet source
    Given variable subject is "Case regarding citrus:randomString(10)"
    Given variable description is "Test for Salesforce Kamelet source"
    Given Camel-K integration salesforce-to-log-property-based is running
    And Camel-K integration salesforce-to-log-property-based should print Login successful
    And Camel-K integration salesforce-to-log-property-based should print Subscribed to channel /topic/
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
    When send POST /services/data/v${camel.kamelet.salesforce-source.salesforce-credentials.apiVersion}/sobjects/Case
    Then receive HTTP 201 Created
    And Camel-K integration salesforce-to-log-property-based should print "Subject":"${subject}"

  Scenario: Remove Camel-K resources
    Given delete Camel-K integration salesforce-to-log-property-based
