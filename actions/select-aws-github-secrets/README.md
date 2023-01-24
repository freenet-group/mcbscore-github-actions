# read-aws-secrets

Github Action zum Einlesen von Werten aus dem AWS Parameter Store. Die Daten werden in Umgebungsvariablen gespeichert.

## Parameter:
### environment
    description: Die Zielumgebung
    required: true
### awsAccessKeyIdProd:
    description: AWS Access Key Id für Zielumgebung prod
### awsAccessKeyId:
    description: AWS Access Key Id andere Zielumgebungen
### awsSecretAccessKeyProd:
    description: AWS Secret Access Key für Zielumgebung prod
### awsSecretAccessKey:
    description: AWS Secret Access Key für andere Zielumgebungen

---

## Ergebnisse:

Die Werte der Github Secrets in Umgebungsvariablen AWS_ACCESS_KEY_ID und AWS_SECRET_ACCESS_KEY übertragen. Abhängig vom Parameter environment kommen die Werte aus den Github Secrets (AWS_ACCESS_KEY_ID und AWS_SECRET_ACCESS_KEY) oder (AWS_ACCESS_KEY_ID_PROD und AWS_SECRET_ACCESS_KEY_PROD). Nachfolgende Steps sollten die Secrets ignorieren und nur noch die (passend zur Zielumgebung gesetzten) Umgebungsvariablen (immer ohne Suffix "_PROD"!) benutzen.

---

## Voraussetzungen:
