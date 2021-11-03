Feature: PostgreSQL Kamelet sink

  Background:
    Given variables
      | id         | citrus:randomNumber(4) |
      | message    | { "id": ${id}, "headline": "Camel K rocks!" } |
      | query      | INSERT INTO headlines VALUES (:#id,:#headline) |

  Scenario: Start PostgreSQL
    Given Database init script
    """
    CREATE TABLE IF NOT EXISTS headlines (id SERIAL PRIMARY KEY, headline VARCHAR);
    """
    Then start PostgreSQL container

  Scenario: Create and verify Kamelet binding
    Given Database connection
      | driver    | ${YAKS_TESTCONTAINERS_POSTGRESQL_DRIVER} |
      | url       | ${YAKS_TESTCONTAINERS_POSTGRESQL_URL} |
      | username  | ${YAKS_TESTCONTAINERS_POSTGRESQL_USERNAME} |
      | password  | ${YAKS_TESTCONTAINERS_POSTGRESQL_PASSWORD} |
    Given Camel-K resource polling configuration
      | maxAttempts          | 200   |
      | delayBetweenAttempts | 2000  |
    Given SQL query max retry attempts: 10
    When load KameletBinding postgresql-sink-test.yaml
    Then Camel-K integration postgresql-sink-test should be running
    And Camel-K integration postgresql-sink-test should print Started source (timer://tick)
    Then SQL query: SELECT headline FROM headlines WHERE ID=${id}
    And verify column HEADLINE=Camel K rocks!

  Scenario: Remove resources
    Given delete KameletBinding postgresql-sink-test
