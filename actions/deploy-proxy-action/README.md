# deploy-proxy-action

Github Action zum Deployment eines Releases eines Proxies.

## Parameter:
### proxyName
    description: 'Der Name des Proxies'
    required: true
### company
    description: 'Die Zielumgebung (md-km)'
    required: true
### componentName
    description: 'Der Name der Komponente'
    required: true
### componentVersion
    description: 'Die Version der Komponente'
    required: true
### host
    description: 'Der Zielhost'
    required: true
### deploymentUser
    description: 'Der Benutzer für das Deployment'
    required: true

---

## Ergebnisse:

Die Komponente wurde auf der Umgebung deployed

---

## Voraussetzungen:

Das Release JAR muß im Verzeichnis ./release liegen.

---

## Aufruf:

      # Deployment
      - name: Deployment
        id: deployRelease
        uses: ./actions/deploy-proxy-action
        with:
          proxyName: "proxyName"
          company: md
          component: "proxy"
          componentVersion: 1.0.0
          host: host.domain.de
          deploymentUser: "deploymentUser"