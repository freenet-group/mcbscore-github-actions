# create-release

Aktion zum Hochladen von GitHub-Release-Asset über den Endpunkt [Upload a release asset](https://docs.github.com/de/rest/releases/assets?apiVersion=2022-11-28#upload-a-release-asset) der GitHub-Release-API.

## Parameter:
### uploadUrl:
    description: Die URL zum Hochladen von Assets in die Version, die von GitHub Actions für zusätzliche Zwecke verwendet werden könnte.
    required: true
### assetName:
    description: Der Name des Asset, das hochgeladen werden soll.
    required: true
### assetContentType:
    description: Der Inhaltstyp des Assets, das hochgeladen werden soll.
    required: false
    default: application/octet-stream

---

## Ergebnisse:

Erstellen von Releases

    # outputs
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
          uploadUrl: ${{ steps.create-release.outputs.upload_url }}
          assetName: metis-ui-${{ env.COMPONENT_VERSION }}.tar.gz
          assetContentType: application/gzip          
```
