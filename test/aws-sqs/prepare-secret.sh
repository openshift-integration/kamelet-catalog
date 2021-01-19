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
oc create secret generic aws-sqs-credentials-secret --from-file=aws-sqs-credentials.properties -n ${YAKS_NAMESPACE}
oc create secret generic aws-sqs-credentials-property --from-file=aws-sqs-credentials.properties -n ${YAKS_NAMESPACE}
oc create secret generic aws-sqs-credentials-uri --from-file=aws-sqs-credentials.properties -n ${YAKS_NAMESPACE}
oc create secret generic aws-sqs-credentials-kamelet --from-file=aws-sqs-credentials.properties -n ${YAKS_NAMESPACE}
oc create secret generic aws-client-config --from-file=.aws/config --from-file=.aws/credentials -n ${YAKS_NAMESPACE}

# bind secret to test by name
oc label secret aws-sqs-credentials-uri yaks.citrusframework.org/test=aws-sqs-source-uri-conf -n ${YAKS_NAMESPACE}
oc label secret aws-sqs-credentials-secret yaks.citrusframework.org/test=aws-sqs-source-secret-conf -n ${YAKS_NAMESPACE}
oc label secret aws-sqs-credentials-property yaks.citrusframework.org/test=aws-sqs-source-property-conf -n ${YAKS_NAMESPACE}

# bind secret to aws-sqs kamelet
oc label secret aws-sqs-credentials-kamelet camel.apache.org/kamelet=aws-sqs-source camel.apache.org/kamelet.configuration=aws-sqs-credentials -n ${YAKS_NAMESPACE}