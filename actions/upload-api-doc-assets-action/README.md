# upload-api-doc-asset-action

Github Action zum Hinzufügen von Open API Yaml Dateien als Release Assets.

## Parameter:
### componentVersion
    description: Die Version des Releases
    required: true
### apiDocYmlPattern
    description: Kommaseparierte Liste von Mustern zum Auffinden der API Doc Dateien
    required: true

---

## Ergebnisse:

Die Asset Dateien wurden hinzugefügt.

---

## Voraussetzungen:

JQ muß installiert sein

    # jq installieren
    - name: Setup jq
      uses: freenet-actions/setup-jq@v2

---

## Aufruf:

      - name: Upload API Doc Assets
        id: uploadApiDocs
        uses: ./upload-api-doc-assets-action
        with:
          version: 1.0.0
          apiDocYmlPattern: ./build/resources/main/static/contentprovider*.yaml