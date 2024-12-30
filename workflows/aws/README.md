# Voraussetzungen für die GitHub Workflows

## GitHub Repository

Folgende Secrets müssen im GitHub-Repository konfiguriert sein:

- **AWS**: AWS-Zugangsdaten müssen als GitHub-Secrets konfiguriert werden:
  - `AWS_ACCESS_KEY_ID`
  - `AWS_SECRET_ACCESS_KEY`
  - `AWS_ACCESS_KEY_ID_PROD`
  - `AWS_SECRET_ACCESS_KEY_PROD`

Nach Umstellung sollten dann die Workflow-Steps "check" und "test" aus dem Pull-Request-Workflow als Pflicht Checks in den Branch Protection Rules definiert werden.

Des Weiteren muss mindestens ein Tag bereits existieren, sodass der Release WF ein Diff ermitteln kann. Wenn kein Tag existiert, muss der Tag 0.0.0 erstellt werden:

```bash
git tag 0.0.0
git push origin 0.0.0
```

## GitHub Workflow Properties

Die Datei `.github/workflow.config` enthält wichtige Einstellungen, die für die Workflows erforderlich sind und in [$GITHUB_OUTPUT](https://docs.github.com/en/actions/writing-workflows/choosing-what-your-workflow-does/passing-information-between-jobs) geschrieben werden und von WF-Steps gelesen werden.

Ein aktuelles Beispiel kann in dieser [Beispiel-Datei](./workflow.config.example) gefunden werden.

## NPM Skripte

Die folgenden `npm run`-Skripte werden in diesem Projekt verwendet und müssen in der `package.json`-Datei definiert sein:

- **`npm run build`**: Baut das Projekt und generiert die notwendigen Artefakte.
- **`npm run deploy --stage=<STAGE>`**: Führt das Deployment für eine spezifische Stage durch, z.B. `git`, `pet`, `prod`.
- **`npm run remove --stage=<STAGE>`**: Entfernt das Deployment für eine spezifische Stage, z.B. `git`, `pet`, `prod`.
- **`npm run generate:sbom`**: Generiert eine SBOM-Datei.
- **`npm run lint`**: Führt Linting-Checks durch, um den Code auf Style-Verstöße und potenzielle Fehler zu prüfen.
- **`npm run lint:fix`**: Führt Linting-Checks durch und versucht, die gefundenen Probleme automatisch zu beheben.
- **`npm run prettier:check`**: Überprüft, ob der Code den Prettier-Formatierungsregeln entspricht. (@deprecated - bitte `npm run format:check` verwenden)
- **`npm run prettier:write`**: Formatiert den Code gemäß den Prettier-Regeln. (@deprecated - bitte `npm run format:write` verwenden)
- **`npm run format:check`**: Überprüft, ob der Code Regeln entspricht.
- **`npm run format:write`**: Formatiert den Code gemäß den Regeln.
- **`npm run test`**: Führt die Unit- und Integrationstests durch und erstellt eine Coverage unter coverage/coverage-summary.json.

## Serverless Framework Plugins

Dieses Projekt verwendet das Serverless Framework für die Verwaltung und Bereitstellung serverloser Anwendungen. Die folgenden Plugins sind in der `serverless.yml`-Datei erforderlich und sollten in der `package.json` unter den `devDependencies` aufgeführt sein:

- **serverless-s3-cleaner**: Ermöglicht das Leeren von S3-Buckets, wenn der Serverless-Stack entfernt wird.

### Beispielkonfiguration in `serverless.yml`

```yaml
service: cure

plugins:
  - serverless-s3-cleaner

custom:
  # Leert S3 Buckets bei sls remove
  serverless-s3-cleaner:
    # Bucket Name muss direkt angegeben werden, funktioniert nicht per !Ref / !GetAtt
    buckets:
      - ${self:provider.stackName}-bucketname
```

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

- **Umgebungsbezogene Zugangsdaten**:
  - `/github/secrets/{environment}/mcbs_app.client_id_sts`: Der Client-ID für das jeweilige Environment.
  - `/github/secrets/{environment}/mcbs_app.client_secret_sts`: Das Client-Secret für das jeweilige Environment.
