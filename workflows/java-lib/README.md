## Workflows

| Workflow | Beschreibung |
| -------- | ------------ |
| build.yml | Baut das Projekt und führt die Tests aus |
| check_code.yml | Prüft den Code auf UTF und Markierungen. Bei Auffäligkeiten wird ein Kommentar erstellt. |
| check_pull_request.yml | Synchronisiert die Labels mit unserem ABRMS/MCBS-Jira-Projekt. Danach wird auf Pflichtlabels geprüft und gegebenfalls Bambi (API) und DOGS (@freenet-group/abr-ms-gh-deployments) informiert. Auch hier wird bei Auffälligkeiten ein Kommentar erstellt. |
| release.yml | Erstellt ein Release mit Release-Notes und deployt das Release auf DEV |
| postBuild.yml | Verteilt die Release-Information an Jira und Teams |

## Umstellung auf CICD

### Main Branch aktualisieren

* Repo mit Main Branch auschecken
* Develop Branch reinziehen
* Direkt ohne PR committen

### GitHub Repo Einstellungen

* settings:
    * General
        * Default-Branch auf "main" setzen. Im neuen Ablauf wird nach jedem Merge eine neue Version gebaut, somit ist kein "develop"- oder "release"-Branch mehr notwendig
    * Labels
        * Labels sind ein wenig versteckt, können aber unter Issues->Labels gefunden werden
        * Folgende Labels anlegen oder Farben anpassen:
            * release:major mit Color #B60205 🔴
            * release:minor mit Color #FBCA04 🟡
            * release:patch mit Color #0E8A16 🟢
            * renovate mit Color #1D76DB

### Anpassung der distribute.yml

Im Repo mcbscore-github-action muss der Workflow distribute.yml mit einen eigenen Branch angepasst werden:

* Hierzu das Repository in die "java-lib" Gruppe verschieben
    * Branch auf "main" setzen
    * Die Gruppe unter "strategy.matrix.repository.group" muss auf "java-lib" geändert werden
    * Die Workflows müssen gegen den env.DEFAULT_WORKFLOWS geprüft werden und können danach ebenfalls entfernt werden
* Im Anschluss den Workflow unter github->actions->workflows->distribute.yml mit dem Branch und der Gruppe java-lib verteilen

* Unter der spotless Verteilung muss der Branch von "develop" auf "main" geändert werden.

* Nach Abschluss des Umbaus und Tests kann dieser PR ebenfalls gemerged werden.

### Anpassung im Repository
In den workflow.properties muß die AtlassianTools Version >=4.0.18 sein.

```properties
ATLASSIAN_DEVELOPER_TOOLS_VERSION=4.0.18
```

Hierzu sollte ein Branch mit PR für den SBOM-Einbau gemacht werden. Dann wird auch gleich ein Release erstellt.

* Prüfen, ob das Distribute die korrekten Workflows verteilt hat oder im Branch die Workflows vorhanden sind
* workflow.properties erweitern

    ```properties
    #...
    DEPENDENCYTRACK_BOM_PATH=./build/reports/
    DEPENDENCYTRACK_BOM_NAME=bom.json
    ```
Das Property JAVA_VERSION ist aus workflow.properties in gradle.properties zu übertragen.
Das Property JAVA_VERSION ist aus workflow.properties zu entfernen.

* cyclonedx-gradle-plugin in der build.gradle hinzufügen

    ```groovy
    plugins {
        //...
        id 'org.cyclonedx.bom' version '1.8.2'
    }

    //...

    cyclonedxBom {
        // includeConfigs is the list of configuration names to include when generating the BOM (leave empty to include every configuration)
        includeConfigs = ["runtimeClasspath"]
        // skipConfigs is a list of configuration names to exclude when generating the BOM
        skipConfigs = ["compileClasspath", "testCompileClasspath"]
        // Specified the type of project being built. Defaults to 'library'
        projectType = "application"
        // Specified the version of the CycloneDX specification to use. Defaults to 1.4.
        schemaVersion = "1.4"
        // The file name for the generated BOMs (before the file format suffix).
        outputName = "bom"
        // The file format generated, can be xml, json or all for generating both
        outputFormat = "json"
        // Exclude BOM Serial Number
        includeBomSerialNumber = false
        // Override component version
        componentVersion = "local"
    }
  
    tasks.processResources.dependsOn(cyclonedxBom)
    ```
* "gradlew clean build" müsste ein sbom file nun erzeugen

### Anpassung des GitHub Repo mit offenem Pull-Request

* settings:
    * Branches
        * "Branch Protection Rules" für "main" anlegen und folgende Einträge setzen:
            * Require pull request reviews before merging
            * Require approvals 1
            * Dismiss stale pull request approvals when new commits are pushed
            * Require status checks to pass before merging
            * Require branches to be up to date before merging
            * Status checks that are required
                * build, checkLabels
                    * build -> Job in der build.yml
                    * checkLabels -> Job in der check_pull_request.yml
                        * Alle 4 checkLabels WF

Der PR dürfte nun auf ein Approval und auf die erfolgreichen Checks bestehen

Im PR muß nun das Label "release:patch" gesetzt werden.

PR mergen. Release Workflow abwarten und dann Release Notes prüfen und ggf. von Hand korrigieren. (Bei Umstellung von alten auf CICD Workflows mit Aktualisierung des main-Branches können vermeintlich betroffene Tickets ermitteln werden, die zu löschen sind.)

In den Releases das letzte SNAPSHOT-Release löschen

### Renovate Assignee Verteilung überarbeiten

Im [Renovate Assignee Repo](https://github.com/freenet-group/mcbscore-renovate/blob/main/renovate-assignees.json) muss der Branch von 'develop' auf 'main' geändert werden.