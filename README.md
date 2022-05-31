# Kamelet Catalog - Openshift

Home for Red Hat Integration Kamelets

See upstream [Apache Camel K Kamelets repository](https://github.com/apache/camel-kamelets/) for a general overview of Kamelets in general.

This repository is not a fork of the Camel K Kamelets repository.

There are some differences on what each repository provides, which is noted below.

## Contributing kamelets

If you are copying kamelets from upstream, you must change the following fields of each Kamelet:

```
# check the current version
camel.apache.org/catalog.version: "kamelet-catalog-1.6-SNAPSHOT"
camel.apache.org/provider: "Red Hat"
```
You can also add any closed source dependency to the Kamelet Binding, for example the MSSQL JDBC Driver `com.microsoft.sqlserver:mssql-jdbc:9.2.1.jre11`, see `sqlserver-sink.kamelet.yaml`.

## Kamelet Binding Examples

Binding examples are highly encouraged to be added under `templates/bindings/camel-k` directory for Kamelet Binding and `templates/bindings/core` for the YAML routes, when the developer wants to add custom logic to the example files.

When the Kamelet Catalog documentation is generated, the examples in each Kamelet documentation page are automatically generated, but the generator code is not wise enough and it may generate a Kamelet Binding that doesn't work, requiring additional steps. In this case, the binding example should be added to the above mentioned directories, and in this case a `kamel bind` example command must be added as a comment in the first line, outlining the correct `kamel bind` usage. 

See `avro-deserialize-action-binding.yaml` for an example of a Kamelet Binding with additional steps or `jms-ibm-mq-sink-binding.yaml` for an example with several parameters in the `sink` section.


When the documentation mechanism runs, it will source this binding example into the kamelet documentation page as example.
