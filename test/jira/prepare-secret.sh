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
oc create secret generic jira-credentials-uri-based --from-file=jira-credentials.properties -n ${YAKS_NAMESPACE}
oc create secret generic jira-credentials-prop-based --from-file=jira-credentials.properties -n ${YAKS_NAMESPACE}
oc create secret generic jira-credentials-secret-based --from-file=jira-credentials.properties -n ${YAKS_NAMESPACE}
oc create secret generic jira-credentials-binding --from-file=jira-credentials.properties -n ${YAKS_NAMESPACE}

oc create secret generic jira-source.jira-credentials --from-file=jira-credentials.properties -n ${YAKS_NAMESPACE}

# bind secret to jira-source test
oc label secret jira-credentials-uri-based yaks.citrusframework.org/test=jira-source-uri-based -n ${YAKS_NAMESPACE}
oc label secret jira-credentials-prop-based yaks.citrusframework.org/test=jira-source-prop-based -n ${YAKS_NAMESPACE}
oc label secret jira-credentials-secret-based yaks.citrusframework.org/test=jira-source-secret-based -n ${YAKS_NAMESPACE}
oc label secret jira-credentials-binding yaks.citrusframework.org/test=jira-binding -n ${YAKS_NAMESPACE}

# bind secret to jira-source kamelet
oc label secret jira-source.jira-credentials camel.apache.org/kamelet=jira-source camel.apache.org/kamelet.configuration=jira-credentials -n ${YAKS_NAMESPACE}
