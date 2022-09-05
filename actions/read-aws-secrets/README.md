# read-aws-secrets

Github Action zum Einlesen von Werten aus dem AWS Parameter Store. Die Daten werden in Umgebungsvariablen gespeichert.

## Parameter:
### awsAccessKeyId
    description: AWS Access Key Id
    required: true
### awsSecretAccessKey
    description: AWS Secret Access Key
    required: true
### awsParameterPairs
    description: Kommaseparierte Liste von Key/Value Paaren einzulesender Parameter. Format: <key> = <value>. Der Key ist der Schlüssel im AWS Parameter Store. Der Value ist der Name der Umgebungsvariable, in die der Wert übertragen werden soll.
    required: true

---

## Ergebnisse:

Die Werte der Einträge im AWS Parameter Store wurden in Umgebungsvariablen übertragen.

---

## Voraussetzungen:

---

## Aufruf:

    - id: read-aws-secrets
      name: Read AWS Secrets
      uses: ./.github/actions/read-aws-secrets
      with:
        awsAccessKeyId: <AWS_ACCESS_KEY_ID>
        awsSecretAccessKey: <AWS_SECRET_ACCESS_KEY>
        awsParameterPairs: |
            /github/secrets/mcbs_token = TOKEN