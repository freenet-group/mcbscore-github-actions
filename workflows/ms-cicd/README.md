## Features der neuen automatischen CICD Pipeline

* Nach jedem PR wird ein Release gebaut und auf Dev deployt
* Automatische Berechnung einer Release-Version
* Einbau weiterer Prüfungen im Pull-Request
    * Code Diff wird auf Markierungen "TODO,FIXME,BUG,DOCME,DEPRECATED" geprüft
    * Pull-Request Labels werden mit Jira synchronisiert um automatisch ms-configuration:yes oder ms-deployment:yes zu
      setzen
        * Wenn eines der beiden Labels mit ":yes" gesetzt wird, dann gibt es eine Meldung an DuA (Dispatching und
          Analyse) und in den Release Notes, dies dient der Info dazu, dass Konfigurationsänderung während des
          Deployments notwendig sind.
    * Prüfung auf release labels: release:patch, release:minor, release:major
    * Automatische Benachrichtigung von DuA, wenn ms-configuration:yes oder ms-deployment:yes gesetzt wird
* Automatische Erstellung von Release-Notes im Release und nicht mehr als Wiki-Seite
* Bambi-Notification (Meldung über neue Releases) beinhaltet nun auch Release Informationen und eine Info ob es ein
  Renovate Release ist
* Deployment Scripte wurden zusammengefasst
* Einbau von SBOM (Software Bill of Material) Meldungen

## Installation

⚠ Es ist nicht möglich einfach nur den Microservice in der distribute.yml umzuhängen. ⚠
Sollten Probleme auftreten, dann bitte die alte distribute.yml wiederherstellen und bei Benjamin Pahl melden.

### Anpassung eines CA Projektes

Dieser Teil der Anleitung ist für unsere auf Clean Architecture basierenden Microservices. Für alle anderen gibt es
unten einen eigenen Abschnitt.

* Workflows fürs erste Mal manuell in das Projekt ersetzen
    * Deployment Scripte wurden zusammengeführt, sodass die Stage Scripte gelöscht werden können

* actions/templates in das Projekt unter .github/actions/templates kopieren

* gradle.properties mit .github/workflow.properties vergleichen
    * ARTIFACT_GROUP_ID und COVERAGE_PATH müssen identisch sein
    * ARTIFACT_NAME und COVERAGE_APP müssen identisch sein
    * Wenn eines dieser beiden Konfigurationen nicht vorhanden sind, wird Sonar keine Coverage finden und somit 0%
      melden. Dasselbe passiert, wenn die SOnar URL unter den AWS Parametern fehlt.

* workflow.properties erweitern

* gradle/cyclonedx.gradle prüfen ob vorhanden
    * Wenn nicht vorhanden, bitte die Plugin-Version gem. Changelogs des Plugins updaten

```properties
#...
DEPENDENCYTRACK_BOM=./build/reports/bom.json
```

* build.gradle publishing sicherstellen

```groovy
// prüfen ob das maven-publish Plugin installiert ist, wenn nicht dann installieren
plugins {
    id 'maven-publish'
}

// ...

// vor den "apply from:" Block einfügen sofern nicht vorhanden
// Publishing Block ist immer notwendig, auch wenn nicht genutzt
publishing {}
```

* gradle/sonar.gradle prüfen ob folgende Werte gesetzt sind

```groovy
//...
property "sonar.projectName", project.ARTIFACT_NAME
property "sonar.projectKey", "$project.ARTIFACT_GROUP_ID:$project.ARTIFACT_NAME"
property "sonar.sourceEncoding", project.FILE_ENCODING
property "sonar.projectVersion", project.ARTIFACT_VERSION
//...
```

### Anpassung eines nicht CA Projektes wie ms-contentprovider

* Workflows fürs erste Mal manuell in das Projekt kopieren bzw. ersetzen

* workflow.properties erweitern

```properties
#...
DEPENDENCYTRACK_BOM=./build/reports/bom.json
```

* cyclonedx-gradle-plugin in der build.gradle hinzufügen

```groovy
plugins {
    //...
    id 'org.cyclonedx.bom' version '1.7.4'
}

//...

// ganz unten dann diesen Block hinzufügen
tasks.named("build") { finalizedBy("cyclonedxBom") }

cyclonedxBom {
    // includeConfigs is the list of configuration names to include when generating the BOM (leave empty to include every configuration)
    includeConfigs = ["runtimeClasspath"]
    // skipConfigs is a list of configuration names to exclude when generating the BOM
    skipConfigs = ["compileClasspath", "testCompileClasspath"]
    // Specified the type of project being built. Defaults to 'library'
    projectType = "application"
    // Specified the version of the CycloneDX specification to use. Defaults to 1.4.
    schemaVersion = "1.4"
    // The file format generated, can be xml, json or all for generating both
    outputFormat = "json"
    // Exclude BOM Serial Number
    includeBomSerialNumber = false
    // Override component version
    componentVersion = "local"
}
```

* bootJar block in der build.gradle hinzufügen

```groovy
//...
jar.enabled = false

bootJar {
    // Sets output jar name
    archiveFileName = "${project.ARTIFACT_NAME}.${archiveExtension.get()}"
    duplicatesStrategy = DuplicatesStrategy.INCLUDE
}
```