# delete-draft-release

Aktion zum Löschen von Draft Releases. 
Zuerst werden die Releases über den Endpunkt [Releases auflisten](https://docs.github.com/de/rest/releases/releases?apiVersion=2022-11-28#list-releases) der GitHub-Release-API ausgewält 
und anschließend die Draft-Releases über den Endpunkt [Release löschen](https://docs.github.com/de/rest/releases/releases?apiVersion=2022-11-28#delete-a-release) der GitHub-Release-API gelöscht.

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
      # Existierende Draft Releases löschen
      - name: Delete draft releases
        if: env.BUILD_TYPE == 'DEVELOP'
        uses: ./mcbscore/github/actions/delete-draft-release
        env:
          GITHUB_TOKEN: ${{ env.TOKEN }}
```
