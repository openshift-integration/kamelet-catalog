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
oc create secret generic slack-credentials-prop-based --from-file=slack-credentials.properties -n ${YAKS_NAMESPACE}
oc create secret generic slack-credentials-uri-based --from-file=slack-credentials.properties -n ${YAKS_NAMESPACE}
oc create secret generic slack-credentials-secret-based --from-file=slack-credentials.properties -n ${YAKS_NAMESPACE}
oc create secret generic slack-uri-binding --from-file=slack-credentials.properties -n ${YAKS_NAMESPACE}

oc create secret generic slack-source.slack-credentials --from-file=slack-credentials.properties -n ${YAKS_NAMESPACE}

# bind secret to test by name
oc label secret slack-credentials-prop-based yaks.citrusframework.org/test=slack-source-prop-based -n ${YAKS_NAMESPACE}
oc label secret slack-credentials-uri-based yaks.citrusframework.org/test=slack-source-uri-based -n ${YAKS_NAMESPACE}
oc label secret slack-credentials-secret-based yaks.citrusframework.org/test=slack-source-secret-based -n ${YAKS_NAMESPACE}
oc label secret slack-uri-binding yaks.citrusframework.org/test=slack-uri-binding -n ${YAKS_NAMESPACE}

# bind secret to slack-source kamelet
oc label secret slack-source.slack-credentials camel.apache.org/kamelet=slack-source camel.apache.org/kamelet.configuration=slack-credentials -n ${YAKS_NAMESPACE}
