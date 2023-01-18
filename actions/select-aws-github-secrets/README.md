# read-aws-secrets

Github Action zum Einlesen von Werten aus dem AWS Parameter Store. Die Daten werden in Umgebungsvariablen gespeichert.

## Parameter:
### environment
    description: Die Zielumgebung
    required: true

---

## Ergebnisse:

Die Werte der Github Secrets in Umgebungsvariablen AWS_ACCESS_KEY_ID und AWS_SECRET_ACCESS_KEY übertragen. Nachfolgende Steps sollten die Secrets ignorieren und nur noch die (passend zur Zielumgebung gesetzten) Umgebungsvariablen (ohne Suffix "_PROD"!) benutzen.

---

## Voraussetzungen:

### Github Action Secrets:
#### AWS_ACCESS_KEY_ID_PROD
    description: AWS Access Key Id für Zielumgebung prod
#### AWS_ACCESS_KEY_ID
    description: AWS Access Key Id andere Zielumgebungen
#### AWS_SECRET_ACCESS_KEY_PROD
    description: AWS Secret Access Key für Zielumgebung prod
#### AWS_SECRET_ACCESS_KEY
    description: AWS Secret Access Key für andere Zielumgebungen
