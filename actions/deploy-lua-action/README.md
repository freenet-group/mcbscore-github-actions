# deploy-lua-action

Github-Action zum Deployment eines lua-Scripts in den [geteilten Teamordner vom Team MCBS-Core](https://github.com/freenet-group/nginx-api/tree/main/shared/teams/mcbs-core) auf einem nginx-Server.

## Parameter:
### pathName:
    description: 'Pfad mit den zu deployenden lua-Skripten'
    required: true
### host:
    description: 'Der Zielhost'
    required: true
### deploymentUser:
    description: 'Der Benutzer für das Deployment'
    required: true
### sshKey:
    description: 'Der SSH Schlüssel'
    required: false

---

## Ergebnisse:

Die Skripte wurden auf der Umgebung deployed und `nginx reload` durchgeführt

---

## Voraussetzungen:

Die zu deployenden Skripte müssen im Verzeichnis `pathName` (i.d.R. also `./release`) liegen.

---

## Aufruf:

      # Deployment
      - name: Deployment
        id: deployRelease
        uses: ./actions/deploy-lua-action
        with:
          pathName: 'release'
          host: 'host.domain.de'
          deploymentUser: 'deploymentUser'