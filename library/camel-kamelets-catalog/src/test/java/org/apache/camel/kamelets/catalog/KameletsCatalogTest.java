/*
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
package org.apache.camel.kamelets.catalog;

import java.util.List;
import java.util.Map;


import io.github.classgraph.ClassGraph;
import org.apache.camel.kamelets.catalog.model.KameletTypeEnum;
import org.apache.camel.tooling.model.ComponentModel;
import org.apache.camel.v1.Kamelet;
import org.apache.camel.v1.kameletspec.Definition;
import org.apache.camel.v1.kameletspec.Template;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.*;

public class KameletsCatalogTest {
    static KameletsCatalog catalog;

    @BeforeAll
    public static void createKameletsCatalog() {
        catalog = new KameletsCatalog();
    }

    @Test
    void testGetKameletsName() throws Exception {
        List<String> names = catalog.getKameletsName();
        assertFalse(names.isEmpty());
    }

    @Test
    void testGetKamelets() throws Exception {
        Map<String, Kamelet> kamelets = catalog.getKamelets();
        assertFalse(kamelets.isEmpty());
    }

    @Test
    void testGetKameletsDefinition() throws Exception {
        Definition props = catalog.getKameletDefinition("aws-sqs-source");
        assertEquals(14, props.getProperties().keySet().size());
        assertTrue(props.getProperties().containsKey("queueNameOrArn"));
    }

    @Test
    void testGetKameletsRequiredProperties() {
        List<String> props = catalog.getKameletRequiredProperties("aws-sqs-source");
        assertEquals(2, props.size());
        assertTrue(props.contains("queueNameOrArn"));
    }

    @Test
    void testGetKameletsDefinitionNotExists() throws Exception {
        Definition props = catalog.getKameletDefinition("word");
        assertNull(props);
    }

    @Test
    void testGetKameletsByProvider() throws Exception {
        List<Kamelet> c = catalog.getKameletByProvider("Red Hat");
        assertFalse(c.isEmpty());
        c = catalog.getKameletByProvider("Eclipse");
        assertTrue(c.isEmpty());
    }

    @Test
    void testGetKameletsByType() throws Exception {
        List<Kamelet> c = catalog.getKameletsByType(KameletTypeEnum.SOURCE.type());
        assertFalse(c.isEmpty());
        c = catalog.getKameletsByType(KameletTypeEnum.SINK.type());
        assertFalse(c.isEmpty());
        c = catalog.getKameletsByType(KameletTypeEnum.ACTION.type());
        assertFalse(c.isEmpty());
    }

    @Test
    void testGetKameletsByGroup() throws Exception {
        List<Kamelet> c = catalog.getKameletsByGroups("AWS S3");
        assertFalse(c.isEmpty());
        c = catalog.getKameletsByGroups("AWS SQS");
        assertFalse(c.isEmpty());
        c = catalog.getKameletsByGroups("Not-existing-group");
        assertTrue(c.isEmpty());
    }

    @Test
    void testGetKameletsByNamespace() throws Exception {
        List<Kamelet> c = catalog.getKameletsByNamespace("AWS");
        assertFalse(c.isEmpty());
        assertEquals(17, c.size());
        c = catalog.getKameletsByGroups("Not-existing-group");
        assertTrue(c.isEmpty());
    }

    @Test
    void testGetKameletsDependencies() throws Exception {
        List<String> deps = catalog.getKameletDependencies("aws-sqs-source");
        assertEquals(4, deps.size());
        deps = catalog.getKameletDependencies("cassandra-sink");
        assertEquals(3, deps.size());
        assertEquals("camel:jackson", deps.get(0));
    }

    @Test
    void testGetKameletsTemplate() throws Exception {
        Template template = catalog.getKameletTemplate("aws-sqs-source");
        assertNotNull(template);
    }

    @Test
    void testAllKameletFilesLoaded() throws Exception {
        int numberOfKameletFiles = new ClassGraph().acceptPaths("/" + KameletsCatalog.KAMELETS_DIR + "/").scan().getAllResources().size();
        assertEquals(numberOfKameletFiles, catalog.getKameletsName().size(), "Some embedded kamelet definition files cannot be loaded.");
    }

    @Test
    void testAllKameletDependencies() throws Exception {
        catalog.getAllKameletDependencies();
    }

    @Test
    void testSupportedHeaders() {
        verifyHeaders("aws-s3-source", 20);
        verifyHeaders("aws-s3-sink", 27);
        verifyHeaders("aws-redshift-source", 0);
        verifyHeaders("aws-not-exists", 0);
        verifyHeaders("azure-storage-blob-sink", 33);
        verifyHeaders("azure-storage-blob-source", 34);
        verifyHeaders("azure-storage-queue-sink", 16);
        verifyHeaders("azure-storage-queue-source", 6);
        verifyHeaders("cassandra-sink", 1);
        verifyHeaders("cassandra-source", 1);
        verifyHeaders("elasticsearch-index-sink", 10);
        verifyHeaders("ftp-source", 10);
        verifyHeaders("ftp-sink", 8);
        verifyHeaders("http-sink", 14);
        verifyHeaders("jira-add-comment-sink", 17);
        verifyHeaders("jira-add-issue-sink", 17);
        verifyHeaders("jira-source", 3);
        verifyHeaders("jms-amqp-10-source", 15);
        verifyHeaders("jms-amqp-10-sink", 18);
        verifyHeaders("jms-ibm-mq-source", 15);
        verifyHeaders("jms-ibm-mq-sink", 18);
        verifyHeaders("kafka-source", 9);
        verifyHeaders("kafka-sink", 5);
        verifyHeaders("log-sink", 0);
        verifyHeaders("mariadb-sink", 8);
        verifyHeaders("mongodb-sink", 12);
        verifyHeaders("mongodb-source", 3);
        verifyHeaders("mysql-sink", 8);
        verifyHeaders("postgresql-sink", 8);
        verifyHeaders("salesforce-create-sink", 1);
        verifyHeaders("salesforce-delete-sink", 1);
        verifyHeaders("salesforce-update-sink", 1);
        verifyHeaders("salesforce-source", 19);
        verifyHeaders("sftp-sink", 8);
        verifyHeaders("sftp-source", 10);
        verifyHeaders("slack-source", 0);
        verifyHeaders("sqlserver-sink", 8);
        verifyHeaders("telegram-source", 5);
        verifyHeaders("timer-source", 2);
    }

    void verifyHeaders(String name, int expected) {
        List<ComponentModel.EndpointHeaderModel> headers = catalog.getKameletSupportedHeaders(name);
        assertEquals(expected, headers.size(), "Component: " + name);
    }

    @Test
    void testGetKameletScheme() throws Exception {
        assertEquals("aws2-s3", catalog.getKameletScheme("aws-s3"));
        assertEquals("aws2-sqs", catalog.getKameletScheme("aws-sqs"));
        assertNull(catalog.getKameletScheme("not-known"));
    }
}
