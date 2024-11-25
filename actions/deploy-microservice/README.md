# deploy-microservice

Github-Action zum Deployment eines Releases einer Komponente.

## Parameter:
### component
    description: Die Komponente
    required: true
### stage
    description: Die Zielumgebung für das Deployment (dev/git/prod/pet)
    required: true
### componentConfigPath
    description: Pfad in dem die Konfiguration der Komponente liegt
    required: true
### checkMkUser
    description: Der Benutzer für den CheckMk Zugriff
    required: true
### checkMkSecret
    description: Das Passwort für den CheckMk Zugriff
    required: true
### deploymentUser
    description: Der Benutzer für das Deployment
    required: true

---

## Ergebnisse:

Die Komponente wurde auf der Umgebung deployed

---

## Voraussetzungen:

JQ muß installiert sein

    # jq installieren
    - name: Setup jq
      uses: freenet-actions/setup-jq@v2

Node muß installiert sein

    # node installieren
    - name: Setup Node JS
      uses: actions/setup-node@v4
      with:
        node-version: '20'
    - run: npm install

Das Release JAR muß im Verzeichnis ./release liegen bzw. - bei Docker-Benutzung - muss stattdessen das Image im Repository vorhanden sein.

---

## Aufruf:

      # Deployment
      - name: Deployment
        id: deployRelease
        uses: ./actions/deploy-microservice-action
        with:
          component: contentprovider
          stage: ${{ inputs.environment }}
          checkMkUser: ${{ secrets.GH_CHECKMK_USER }}
          checkMkSecret: ${{ secrets.GH_CHECKMK_SECRET }}
          deploymentUser: ${{ secrets.GH_DEPLOYMENT_USER }}
