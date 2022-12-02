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

MODULESROOT := modules/ROOT
PAGES := $(MODULESROOT)/pages
DOC_GENERATOR := doc-generator

default: adoc

clean:
	rm -f $(PAGES)/*{source,sink,action}.adoc

go:
ifeq (, $(shell command -v go 2> /dev/null))
	$(error "No go binary found in PATH. Please install and re-run")
endif

adoc: clean go
	cd $(DOC_GENERATOR) && go run . ../../

.PHONY: go adoc
