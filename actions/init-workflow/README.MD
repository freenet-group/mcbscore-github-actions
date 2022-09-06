# init-workflow

Github Action zum Initialisieren von Workflows. Dazu gehören:
- Einlesen von build.properties/workflow.properties
- Installation von JAVA

## Parameter:
### installJava
    description: JDK installieren?
    type: boolean
    default: false

---

## Ergebnisse:

---

## Voraussetzungen:

AWS-Secrets wurden eingelesen.

---

## Aufruf:

      - id: init-workflow
        name: Initialize Workflow
        uses: ./mcbscore/github/actions/init-workflow
        with:
          installJava: true