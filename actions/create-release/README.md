# create-release

Aktion zum Erstellen von Releases über die GitHub-Release-API, insbesondere den Endpunkt „Release erstellen“ 
https://docs.github.com/en/rest/releases/releases#create-a-release

## Parameter:
### tagName:
    description: Der Name des Tags
    required: true
### releaseName:
    description: Der Name des Releases
    required: true
### draft:
    description: true (unveröffentlichten) Release-Entwurf zu erstellen, \
    false, um einen veröffentlichten Release zu erstellen. \
    required: false
    default:  false

---

## Ergebnisse:

Erstellen von Releases

    # outputs
      id: Die Release-ID.
      html_url: Die URL, zu der Benutzer navigieren können, um die Version anzuzeigen.
      upload_url: Die URL zum Hochladen von Assets in die Version, die von GitHub Actions für zusätzliche Zwecke verwendet werden könnte.

---

## Voraussetzungen:

muß installiert sein

    # Github CLI installieren
    - name: Setup Github CLI
      uses: freenet-actions/setup-github-cli@v2

    # jq installieren
    - name: Setup jq
      uses: freenet-actions/setup-jq@v2

---

## Aufruf:

     # Release erstellen
      - name: Create Release
        id: create_release
        uses: ./mcbscore/github/actions/create-release
        with:
          tagName: ${{ env.TAG_PREFIX }}${{ env.COMPONENT_VERSION }}
          releaseName: ${{ env.RELEASE_PREFIX }}${{ env.COMPONENT_VERSION }}
          draft: ${{ env.DRAFT }}          
