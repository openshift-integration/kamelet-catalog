/**
 * Copyright (C) 2021 Red Hat, Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *         http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import java.io.File
import java.nio.file.Files
import java.nio.file.Paths
import java.nio.file.StandardCopyOption
import java.util.Properties


def updateKameletDirectory(String directoryName, String replaceVersion) {
    println "#### updateKamelets BEGIN"

    File directory = new File(directoryName)
    File[] files = directory.listFiles()
    String oldVersion = "mvn:org.apache.camel.kamelets:camel-kamelets-utils:[A-Za-z0-9-.]+"
    String newVersion = "github:openshift-integration.kamelet-catalog:camel-kamelets-utils:" + replaceVersion

    String catalogOldVersion = "camel.apache.org/catalog.version:.*"
    String catalogNewVersion = "camel.apache.org/catalog.version: \"" + replaceVersion + "\""

    String kameletUtilsOldVersion = "github:openshift-integration.kamelet-catalog:camel-kamelets-utils:[A-Za-z0-9-.]+"
    String kameletUtilsNewVersion = "mvn:org.apache.camel.kamelets:camel-kamelets-utils:" + replaceVersion

    for (File f in files) {
        if (f.getName().endsWith(".kamelet.yaml")) {
            String kameletFile = f.getName() 
            println "#### Replacing content in " + kameletFile + " with " + newVersion
            new File( kameletFile + ".bak" ).withWriter { w ->
                new File( kameletFile ).eachLine { line ->
                    w << line.replaceAll(oldVersion, newVersion)
                            .replaceAll(catalogOldVersion, catalogNewVersion)
                            .replaceAll(kameletUtilsOldVersion, kameletUtilsNewVersion) + System.getProperty("line.separator")
                }
            }
            Files.copy(Paths.get(kameletFile + ".bak"), Paths.get(kameletFile), StandardCopyOption.REPLACE_EXISTING)
            boolean deleted = new File(kameletFile + ".bak").delete()
        }
    }

    println "#### updateKamelets END"
}

return this
