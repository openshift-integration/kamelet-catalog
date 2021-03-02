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
oc create secret generic telegram-credentials-uri-based --from-file=telegram-credentials.properties -n ${YAKS_NAMESPACE}
oc create secret generic telegram-credentials-secret-based --from-file=telegram-credentials.properties -n ${YAKS_NAMESPACE}
oc create secret generic telegram-credentials-prop-based --from-file=telegram-credentials.properties -n ${YAKS_NAMESPACE}
oc create secret generic telegram-uri-binding --from-file=telegram-credentials.properties -n ${YAKS_NAMESPACE}
oc create secret generic telegram-inmem-binding --from-file=telegram-credentials.properties -n ${YAKS_NAMESPACE}

oc create secret generic telegram-source.telegram-credentials --from-file=telegram-credentials.properties -n ${YAKS_NAMESPACE}

# bind secret to test by name
oc label secret telegram-credentials-uri-based yaks.citrusframework.org/test=telegram-source-uri-based -n ${YAKS_NAMESPACE}
oc label secret telegram-credentials-secret-based yaks.citrusframework.org/test=telegram-source-secret-based -n ${YAKS_NAMESPACE}
oc label secret telegram-credentials-prop-based yaks.citrusframework.org/test=telegram-source-prop-based -n ${YAKS_NAMESPACE}
oc label secret telegram-uri-binding yaks.citrusframework.org/test=telegram-uri-binding -n ${YAKS_NAMESPACE}
oc label secret telegram-inmem-binding yaks.citrusframework.org/test=telegram-inmem-binding -n ${YAKS_NAMESPACE}

# bind secret to kamelet
oc label secret telegram-source.telegram-credentials camel.apache.org/kamelet=telegram-source camel.apache.org/kamelet.configuration=telegram-credentials -n ${YAKS_NAMESPACE}
