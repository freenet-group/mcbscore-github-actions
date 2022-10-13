# microservice-docker-image-action

Github Action zur Erstellung eines Docker Images f�r einen Microservice. Zus�tzlich wird das erstellte Image in Github Packages hinterlegt.

## Parameter:
### componentName
    description: Der Name der Komponente
    required: true
### componentVersion
    description: Die Version der Komponente
    required: true
### javaVersion
    description: Die JAVA Version
    required: false
    default: 11
### language
    description: Die Sprach Einstellung
    required: false
    default: de_DE.UTF-8

---

## Ergebnisse:

Ein Docker Image wurde erstellt und in Github Packages hinterlegt

---

## Voraussetzungen:

Das Release JAR mu� im Unterverzeichnis ./release der Action liegen.

---

## Aufruf:

      # Docker Image erstellen
      - name: Create and publish docker image
        id: createDockerImage
        uses: ./microservice-docker-image-action
        with:
          componentName: ms-contentprovider
          componentVersion: 1.0.0