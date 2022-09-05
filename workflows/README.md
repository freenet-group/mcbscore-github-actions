# workflows
Enthält alle Workflows für MCBS Core

Über den Distribute Workflow kann der aktuelle Stand auf die Repositories vom MCBS Core übertragen werden.

## Distribute Workflow

Über den Distribute Workflow werden die Vorlagen auf die einzelnen Repositories verteilt.

Die Konfiguration der Verteilung erfolgt über eine Github Matrix mit dem Namen *repository*:

Beispiel:
```
jobs:
  dispatch:
    runs-on: ubuntu-latest
    strategy:
      matrix:
       repository:
          - { name: ms-freeprint-router, branch: develop, group: ms, workflows: "build, deployment, deployment_dev, deployment_git, dockerImage, postBuild" }
```
Die Matrix Repository hat folgende Attribute:
- name: Name des Zielrepositories ohne Organisation (hier wird freenet-group vorausgesetzt)
- branch: Branch des Zielrepositories, auf dem die Aktualisierung erfolgen soll
- group: Workflow Gruppe. Verweis auf das zu verwendende Quellverzeichnis unter [workflows](workflows)
- workflows: Kommaseparierte Liste der Dateinamen (ohne .yml Endung), der zu übertragenden Workflows

Für die Verteilung der Workflows gelten folgende Regeln.
- geänderte Workflows werden aktualisiert
- neue Workflows werden hinzugefügt
- existierende Workflows, die nicht mehr in der Matrix (Attribut matrix.repository.workflows) aufgeführt sind, werden gelöscht

## Vorlagen

Die Kopiervorlagen für die einzelnen Workflows liegen im Verzeichnis [workflows](workflows).
Innerhalb dieses Verzeichnisses erfolgt eine weitere Unterteilung in Gruppen (Microservice, Proxy, ...).
Für jede Gruppe existiert ein Unterverzeichnis, in dem deren Workflows hinterlegt werden.

## Ziel Repositories

Alle Repositories, die Ziel der Verteilung sind, muß das Team [MCBS Core Admins](https://github.com/orgs/freenet-group/teams/mcbs-core-admins) Admin Rechte haben.

## Docker Build

Der Build des Docker Images bei Microservices ist Teil des Haupt-Build-Workflows (damit das Image dem auch enthaltenen Dev-Deployment zur Verfügung steht). Man kann ihn mit `DOCKER_ENABLED=false` in _ServiceRepo_/.github/build.properties unterdrücken.

Wenn im Hauptverzeichnis des Service die Datei Dockerfile existiert, wird die benutzt, sonst das von der hier verwendeten Action mitgebrachte Standard-Dockerfile. Eine Mischung ("halb-custom" Docker Image) ist möglich, indem man im Service kein eigenes Dockerfile hat, aber in _ServiceRepo_/.github/build.properties eine Property `DOCKER_INCLUDE_DIR`, mit der man ein Verzeichnis angibt, dessen Inhalt in das Home-Verzeichnis im (vom Standard Dockerfile definierten) Image kopiert wird.

(Ob das Docker Image im Deployment benutzt wird, ist anderswo (Repository ms-deployment) geregelt.)