# replace-aws-parameters

Github Action zum Ersetzen von Schlüsseln in Dateien durch Werte aus dem AWS Parameter Store.
Die Datei mit den Ersetzungsregeln muß für jede Regel folgende Syntax erfüllen: **FILE:KEY=AWS-KEY**

- FILE: Relativer Pfad der Datei, in welcher die Ersetzung erfolgen soll
- KEY: Zu ersetzende Zeichenkette
- AWS-KEY: Schlüssel im AWS Parameter Store für den ersetzenden Wert  

## Parameter:
### awsKey
    description: Der Key für den AWS Zugriff
    required: true
### awsSecret
    description: Das Secret für den AWS Zugriff
    required: true
### directory
    description: Das Verzeichnis, in dem die Ersetzungen erfolgen sollen
    required: true
### parameterFile
    description: Die Datei mit den Ersetzungsregeln
    required: true

---

## Ergebnisse:

Die Schlüssel wurden ersetzt.

---

## Voraussetzungen:

JQ muß installiert sein

    # jq installieren
    - name: Setup jq
      uses: freenet-actions/setup-jq@v2

---

## Aufruf: