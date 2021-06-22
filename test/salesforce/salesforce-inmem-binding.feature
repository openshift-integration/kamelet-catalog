Feature: Salesforce Kamelet

  Background:
    Given Disable auto removal of Camel-K resources
    Given Disable auto removal of Kamelet resources
    Given create Knative channel messages

  Scenario: Verify Kamelet source
    Given Kamelet salesforce-source is available
    Given load KameletBinding salesforce-to-inmem.yaml
    Given load KameletBinding inmem-to-log.yaml
    Then KameletBinding salesforce-to-inmem should be available
    And Camel-K integration salesforce-to-inmem is running

    And KameletBinding inmem-to-log should be available
    Given variable loginfo is "Installed features"
    Then Camel-K integration inmem-to-log should print ${loginfo}
    And Camel-K integration inmem-to-log should print ${loginfo}
    Then sleep 10000 ms

    #obtain token
    Given variable token_request is "grant_type=password&client_id=${camel.kamelet.salesforce-source.salesforce-credentials.clientId}&client_secret=${camel.kamelet.salesforce-source.salesforce-credentials.clientSecret}&username=${camel.kamelet.salesforce-source.salesforce-credentials.userName}&password=${camel.kamelet.salesforce-source.salesforce-credentials.password}"
    Given URL: ${camel.kamelet.salesforce-source.salesforce-credentials.loginUrl}
    And HTTP request header Content-Type="application/x-www-form-urlencoded"
    And HTTP request body: ${token_request}
    When send POST /services/oauth2/token
    Then verify HTTP response expression: $.instance_url="@variable(instance_url)@"
    And verify HTTP response expression: $.access_token="@variable(access_token)@"
    And receive HTTP 200 OK

    #get account id
    Given URL: ${instance_url}
    And HTTP request header Authorization="Bearer ${access_token}"
    And HTTP request header Content-Type="application/json"
    And HTTP request query parameter q="citrus:urlEncode('SELECT Id,Name FROM Account LIMIT 1')"
    When send GET /services/data/v${camel.kamelet.salesforce-source.salesforce-credentials.apiVersion}/query/
    Then verify HTTP response expression: $.records[0].Id="@variable(account_id)@"
    And receive HTTP 200 OK

    #send message
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
    When send POST /services/data/v${camel.kamelet.salesforce-source.salesforce-credentials.apiVersion}/sobjects/Case
    Then receive HTTP 201 Created
    And Camel-K integration inmem-to-log should print "Subject":"${subject}"

  Scenario: Remove Camel-K resources
    Given delete KameletBinding salesforce-to-broker
    Given delete KameletBinding broker-to-log
