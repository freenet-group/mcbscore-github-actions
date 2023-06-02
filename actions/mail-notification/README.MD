# Send (mail-notification) mail Github Action

GitHub-Action zum Versand von Releasebuild-Notifications im E-Mail-Format an einen MS-Teams-Channel


## Nutzung

```yaml
 - name: Send notification as mail
        uses: ./mcbscore/github/actions/mailNotification
        with:
          component:  ${{ steps.read_jira_component.outputs.value }} 
          componentVersion: ${{ github.event.inputs.releaseVersion }}
          goingLiveDate: "unbestimmt"
          issueList: ${{ github.event.inputs.issueList }} 
          hasSql: ${{ steps.cR.outputs.sql }}
          hasConfiguration: ${{ steps.cR.outputs.config }}
          hasDependencies: ${{ steps.cR.outputs.dependency }}
          additionalText: "extra"
          epic: "epic"
          mailAddress: ${{ inputs.mailAddress }}
		  purpose: ${{ inputs.purpose }}
          atlassianToolsVersion:
          repositoryName:
          logLevel:
              