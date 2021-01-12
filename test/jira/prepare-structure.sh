#!/bin/sh

# Licensed to the Apache Software Foundation (ASF) under one or more
# contributor license agreements.  See the NOTICE file distributed with
# this work for additional information regarding copyright ownership.
# The ASF licenses this file to You under the Apache License, Version 2.0
# (the "License"); you may not use this file except in compliance with
# the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# create secret from properties file
oc create secret generic jira-credentials --from-file=jira-credentials.properties -n ${YAKS_NAMESPACE}

# bind secret to jira-source test
oc label secret jira-credentials yaks.citrusframework.org/test=jira-source -n ${YAKS_NAMESPACE}

# create InMemoryChannel messages
oc apply -f inmem.yaml -n ${YAKS_NAMESPACE}

# create logger-sink Kamelet
oc apply -f logger-sink.kamelet.yaml -n ${YAKS_NAMESPACE}

# create KameletBinding inmem-to-log from InMemoryChannel messages to logger-sink Kamelet
oc apply -f inmem-to-log.binding.yaml -n ${YAKS_NAMESPACE}

# create integration jira-source kamelet to InMemoryChannel messages, with property based configuration
kamel run jira-to-inmem.groovy --property-file=jira-credentials.properties -w -n ${YAKS_NAMESPACE}
