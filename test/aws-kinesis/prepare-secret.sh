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
oc create secret generic aws-kinesis-credentials --from-file=aws-kinesis-credentials.properties -n ${YAKS_NAMESPACE}
oc create secret generic aws-kinesis-credentials-uri-based --from-file=aws-kinesis-credentials.properties -n ${YAKS_NAMESPACE}
oc create secret generic aws-kinesis-credentials-secret-based --from-file=aws-kinesis-credentials.properties -n ${YAKS_NAMESPACE}
oc create secret generic aws-kinesis-credentials-prop-based --from-file=aws-kinesis-credentials.properties -n ${YAKS_NAMESPACE}
oc create secret generic aws-kinesis-credentials-uri-binding --from-file=aws-kinesis-credentials.properties -n ${YAKS_NAMESPACE}

oc create secret generic aws-client-config --from-file=.aws/config --from-file=.aws/credentials -n ${YAKS_NAMESPACE}

# create secret for Kamelet
oc create secret generic aws-kinesis-source.aws-kinesis-credentials --from-file=aws-kinesis-credentials.properties -n ${YAKS_NAMESPACE}

# bind secret to test by name
oc label secret aws-kinesis-credentials yaks.citrusframework.org/test=aws-kinesis-source -n ${YAKS_NAMESPACE}
oc label secret aws-kinesis-credentials-uri-based yaks.citrusframework.org/test=aws-kinesis-source-uri-based -n ${YAKS_NAMESPACE}
oc label secret aws-kinesis-credentials-secret-based yaks.citrusframework.org/test=aws-kinesis-source-secret-based -n ${YAKS_NAMESPACE}
oc label secret aws-kinesis-credentials-prop-based yaks.citrusframework.org/test=aws-kinesis-source-prop-based -n ${YAKS_NAMESPACE}
oc label secret aws-kinesis-credentials-uri-binding yaks.citrusframework.org/test=aws-kinesis-uri-binding -n ${YAKS_NAMESPACE}

# bind secret to Kamelet by name
oc label secret aws-kinesis-source.aws-kinesis-credentials camel.apache.org/kamelet=aws-kinesis-source camel.apache.org/kamelet.configuration=aws-kinesis-credentials -n ${YAKS_NAMESPACE}

