# create-release

Aktion zum Hochladen von GitHub-Release-Asset über den Endpunkt [Upload a release asset](https://docs.github.com/de/rest/releases/assets?apiVersion=2022-11-28#upload-a-release-asset) der GitHub-Release-API.

## Parameter:
### releaseId:
    description: Die ID des Releases, zu dem die Asset hinzugefügt werden sollen.
    required: true
### assetName:
    description: Der Name des Asset, das hochgeladen werden soll.
    required: true
### assetPath:
    description: Der Pfad zum Asset, das hochgeladen werden soll.
    required: true
### assetContentType:
    description: Der Inhaltstyp des Assets, das hochgeladen werden soll.
    required: false
    default: application/octet-stream

---

## Ergebnisse:

Erstellen von Releases

    # outputs
        id: Die ID des hochgeladenen Asset.
        browserDownloadUrl: Die URL zum Herunterladen des Asset.
---

## Voraussetzungen:

muß installiert sein
 ```yaml
   # Github CLI installieren
    - name: Setup Github CLI
      uses: freenet-actions/setup-github-cli@v2

    # jq installieren
    - name: Setup jq
      uses: freenet-actions/setup-jq@v2
```

## Aufruf:
```yaml
     #  Release ZIP hinzufügen
      - name: Upload Release ZIP   
        id: upload-release-asset
        uses: ./mcbscore/github/actions/upload-release-asset
        with:
          releaseId: ${{ steps.create-release.outputs.id }}
          assetName: metis-ui-${{ env.COMPONENT_VERSION }}.tar.gz
          assetPath: ./metis-ui-${{ env.COMPONENT_VERSION }}.tar.gz
          assetContentType: application/gzip          
```
