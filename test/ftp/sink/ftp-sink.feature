Feature: FTP Kamelet sink

  Background:
    Given variables
      | ftp.server.host     | ftp-server  |
      | ftp.server.port     | 21          |
      | ftp.server.username | admin       |
      | ftp.server.password | admin       |
      | ftp.server.timeout   | 15000      |
      | auto.handle.commands | TYPE,PORT,PASV |
      | directoryName       | /           |
      | passiveMode         | true        |
      | file                | message.txt |
      | message             | Camel K rocks! |

  Scenario: Create FTP server
    Given create Kubernetes service ftp-server with port mappings
      | 21    | 20021 |
      | 20022 | 20022 |
    Given load endpoint ftp-server.groovy

  Scenario: Create Kamelet binding
    Given Camel K resource polling configuration
      | maxAttempts          | 200   |
      | delayBetweenAttempts | 2000  |
    When load Kubernetes custom resource ftp-sink-test.yaml in kameletbindings.camel.apache.org
    Then Camel K integration ftp-sink-test should be running

  Scenario: Verify FTP file created
    When endpoint ftp-server receives body
    """
    {
      "signal": "STOR",
      "arguments": "${file}"
    }
    """
    Then endpoint ftp-server sends body
    """
    {
      "success": true
    }
    """

  Scenario: Verify file content
    Then receive Camel exchange from("file:~/ftp/user/admin?directoryMustExist=true&fileName=${file}") with body: ${message}

  Scenario: Remove resources
    Given delete KameletBinding ftp-sink-test
    And delete Kubernetes service ftp-server
