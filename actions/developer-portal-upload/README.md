# developer-portal-upload

Github Action zum Upload der YAML Dateien eines Releases einer Komponente in das Developer-Portal.

## Parameter:
### component
    description: Die Komponente
    required: true
### componentVersion
    description: Die Version des Releases
    required: true
### stage
    description: Die Zielumgebung für das Deployment (dev/git/prod)
    required: true
### componentConfigPath
    description: Pfad in dem die Konfiguration der Komponente liegt
    required: true

---

## Ergebnisse:

Die API Doc wurde in das Developer Portal hochgeladen.

---

## Aufruf:

      # Developer Portal Upload
      - name: Developer Portal Upload
        id: developer_portal_upload
        uses: ./actions/developer-portal-upload-action
        with:
          component: contentprovider
          componentVersion: 1.0.0-SNAPSHOT
          stage: dev