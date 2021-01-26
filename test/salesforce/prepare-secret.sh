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
oc create secret generic salesforce-credentials-kamelet --from-file=salesforce-credentials.properties -n ${YAKS_NAMESPACE}
oc create secret generic salesforce-credentials-uri --from-file=salesforce-credentials.properties -n ${YAKS_NAMESPACE}
oc create secret generic salesforce-credentials-property --from-file=salesforce-credentials.properties -n ${YAKS_NAMESPACE}
oc create secret generic salesforce-credentials-secret --from-file=salesforce-credentials.properties -n ${YAKS_NAMESPACE}

oc create secret generic salesforce-binding-credentials --from-file=salesforce-credentials.properties -n ${YAKS_NAMESPACE}

# bind secret to test by name
oc label secret salesforce-credentials-uri yaks.citrusframework.org/test=salesforce-source-uri-based -n ${YAKS_NAMESPACE}
oc label secret salesforce-credentials-property yaks.citrusframework.org/test=salesforce-source-property-based -n ${YAKS_NAMESPACE}
oc label secret salesforce-credentials-secret yaks.citrusframework.org/test=salesforce-source-secret-based -n ${YAKS_NAMESPACE}

# bind secret to salesforce-source kamelet
oc label secret salesforce-credentials-kamelet camel.apache.org/kamelet=salesforce-source camel.apache.org/kamelet.configuration=salesforce-credentials -n ${YAKS_NAMESPACE}

oc label secret salesforce-binding-credentials yaks.citrusframework.org/test=salesforce-binding -n ${YAKS_NAMESPACE}
