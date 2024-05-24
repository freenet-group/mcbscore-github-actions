# init-workflow

Github-Action zum Initialisieren von Workflows. Dazu gehören:
- Einlesen von build.properties/workflow.properties
- Installation von JAVA

## Parameter:
### installJava
    description: JDK installieren?
    type: boolean
    default: false
### installJavaWithNashornEngine
    description: JDK mit Nashorn Engine installieren?
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
### installGithubCli
    description: Github CLI installieren?
    type: boolean
    default: false
### installGradleSetup
    description: Soll gradle eingerichtet werden?
    type: boolean
    default: false
### configurationPrefix:
    description: Prefix für workflow.properties Dateien. Beispiel: customer-workflow.properties
    type: string
    required: false
    default:
### lookupBasePath:
    description: Basispfad für den Lookup der Properties Dateien
    type: string
    required: false
    default: .

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
          installGithubCli: true
          installJq: true
          configurationPrefix: ${{ matrix.product.name }}
          lookupBasePath: ${{ github.workspace }}
