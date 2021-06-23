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
    boolean useJitpack = replaceVersion.endsWith("-SNAPSHOT")
    
    String kameletUtilsMvnSelector = "mvn:org\\.apache\\.camel\\.kamelets:camel-kamelets-utils:[A-Za-z0-9-.]+"
    String kameletUtilsJitpackSelector = "github:openshift-integration\\.kamelet-catalog:camel-kamelets-utils:[A-Za-z0-9-.]+"

    String kameletUtilsMvnVersion = "mvn:org.apache.camel.kamelets:camel-kamelets-utils:" + replaceVersion
    String kameletUtilsJitpackVersion = "github:openshift-integration.kamelet-catalog:camel-kamelets-utils:" + replaceVersion
    String kameletUtilsNewVersion = useJitpack ? kameletUtilsJitpackVersion : kameletUtilsMvnVersion

    String catalogVersionAnnotationSelector = "camel\\.apache\\.org/catalog\\.version:.*"
    String catalogVersion = "camel.apache.org/catalog.version: \"" + replaceVersion + "\""

    File directory = new File(directoryName)
    File[] files = directory.listFiles()

    for (File f in files) {
        if (f.getName().endsWith(".kamelet.yaml")) {
            String kameletFile = f.getName() 
            println "#### Setting version in " + kameletFile + " to " + catalogVersion
            println "#### Replacing content in " + kameletFile + " with " + kameletUtilsNewVersion
            new File( kameletFile + ".bak" ).withWriter { w ->
                new File( kameletFile ).eachLine { line ->
                    w << line.replaceAll(catalogVersionAnnotationSelector, catalogVersion)
                            .replaceAll(kameletUtilsMvnSelector, kameletUtilsNewVersion)
                            .replaceAll(kameletUtilsJitpackSelector, kameletUtilsNewVersion) + System.getProperty("line.separator")
                }
            }
            Files.copy(Paths.get(kameletFile + ".bak"), Paths.get(kameletFile), StandardCopyOption.REPLACE_EXISTING)
            boolean deleted = new File(kameletFile + ".bak").delete()
        }
    }

    println "#### updateKamelets END"
}

return this
