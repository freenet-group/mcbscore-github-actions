# download-release-assets

Github Action zum Download aller Release Assets, die dem Muster entsprechen. Die Assets werden in dem angegebenen Zielverzeichnis abgelegt.

## Parameter:
  ### version
    description: Die Version des Releases
    required: true
  ### assetPattern
    description: Pattern für den Namen des Assets
    required: true
  ### targetPath
    description: Ein Zielverzeichnis
    required: true
  ### token
    description: Ein Github Token
    required: true
  ### repository
    description: Assets Repository
    required: true
    default: ${{ github.repository }}

---

## Ergebnisse:

Die Asset Datei wird im angegebenen Verzeichnis hinterlegt.

---

## Voraussetzungen:

JQ muß installiert sein

    # jq installieren
    - name: Setup jq
      uses: freenet-actions/setup-jq@v2

---

## Aufruf:

      # Release Download
      - name: Download Release
        id: downloadRelease
        uses: ./download-release-assets-action
        with:
          version: 1.0.0
          assetPattern: '-1.0.0.jar'
          targetPath: './release'
          token: ${{ secrets.GH_REPO_MCBS }}