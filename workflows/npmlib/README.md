# Voraussetzungen für die GitHub Workflows

## GitHub Repository

Folgende Voraussetzungen müssen im GitHub-Repository konfiguriert sein:

- **AWS**: AWS-Zugangsdaten müssen als GitHub-Secrets konfiguriert werden:
  - `AWS_ACCESS_KEY_ID`
  - `AWS_SECRET_ACCESS_KEY`
  - `AWS_REGION`

Nach Umstellung sollten dann die Workflows Steps `check` und `test` aus dem Pull-Request-Workflows als Pflicht Checks in den Branch Protection Rules definiert werden.

Des Weiteren muss mindestens ein Tag bereits existiertieren, sodass der Release WF ein Diff ermitteln kann. Wenn kein Tag existiert, muss der Tag 0.0.0 erstellt werden:

```bash
git tag 0.0.0
git push origin 0.0.0
```

## GitHub Workflow Properties

Diese Datei (`.github/workflow.config`) enthält wichtige Einstellungen, die für die Workflows erforderlich sind und in $GITHUB_OUTPUT geschrieben werden:

```properties
SBOM_FILE=./src/.generated/sbom.json
JIRA_COMPONENT=<YOUR_COMPONENT>
NODE_VERSION=20.x
```

## NPM Skripte

Die folgenden `npm run`-Skripte werden in diesem Projekt verwendet und müssen in der `package.json`-Datei definiert sein:

- **`npm run build`**: Baut das Projekt und generiert die notwendigen Artefakte.
- **`npm run generate:sbom`**: Generiert eine SBOM-Datei.
- **`npm run lint`**: Führt Linting-Checks durch, um den Code auf Style-Verstöße und potenzielle Fehler zu prüfen.
- **`npm run lint:fix`**: Führt Linting-Checks durch und versucht, die gefundenen Probleme automatisch zu beheben.
- **`npm run prettier:check`**: Überprüft, ob der Code den Prettier-Formatierungsregeln entspricht.
- **`npm run prettier:write`**: Formatiert den Code gemäß den Prettier-Regeln.
- **`npm run test`**: Führt die Unit- und Integrationstests durch und erstellt eine Coverage unter coverage/coverage-summary.json.

## AWS Parameter Store

Die Workflows in diesem Projekt verwenden AWS Systems Manager (SSM), um sicherheitskritische Daten wie JIRA-Zugangsdaten und API-Keys sicher zu speichern und abzurufen. Folgende Parameter müssen in AWS SSM (ParameterStore) konfiguriert sein:

- **JIRA Zugangsdaten**:

  - `/github/secrets/mcbs_token`: Enthält das Token für die Authentifizierung bei JIRA.
  - `/github/secrets/mcbstest_jiracloud_credentials`: Enthält die JIRA Cloud-Zugangsdaten im Format `username:password`.
  - `/github/common/jira/jira_cloud_url`: Enthält die URL zum JIRA Cloud-Server.

- **Dependency Track Zugangsdaten**:

  - `/github/secrets/dependencytrack_protocol`: Das Protokoll (z.B. https) für den Zugriff auf Dependency Track.
  - `/github/secrets/dependencytrack_hostname`: Der Hostname des Dependency Track Servers.
  - `/github/secrets/dependencytrack_port`: Der Port des Dependency Track Servers.
  - `/github/secrets/dependencytrack_api_key`: Der API-Key für den Zugriff auf Dependency Track.
