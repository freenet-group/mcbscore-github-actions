# init-workflow

Github-Action zum Initialisieren von Workflows. Dazu gehören:
- Einlesen von build.properties/workflow.properties
- Installation von JAVA

## Parameter:
### installJava
    description: JDK installieren?
    type: boolean
    default: false
### installNodeJs
    description: Node.js installieren?
    type: boolean
    default: false
### installJq
    description: jq installieren?
    type: boolean
    default: false

---

## Ergebnisse:

---

## Voraussetzungen:

AWS-Secrets wurden eingelesen.

Folgende Properties müssen in der Datei workflow.properties enthalten sein:
- JAVA_VERSION, wenn Java installiert werden soll
- NODEJS_VERSION, wenn Node.js installiert werden soll

---

## Aufruf:

      - id: init-workflow
        name: Initialize Workflow
        uses: ./mcbscore/github/actions/init-workflow
        with:
          installJava: true