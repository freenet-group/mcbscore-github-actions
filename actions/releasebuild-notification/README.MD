# Send (releasebuild-notification) mail Github Action

GitHub-Action zum Versand von Releasebuild-Notifications im E-Mail-Format an einen MS-Teams-CHannel


## Nutzung

```yaml
 - name: Send notification as mail
        uses: ./mcbscore/github/actions/releasebuild-notification
        with:
          component:  ${{ steps.read_jira_component.outputs.value }} 
          componentVersion: ${{ inputs.releaseVersion }}
          goingLiveDate: "unbestimmt"
          issueList: ${{ inputs.issueList }} 
          hasSql: ${{ steps.cR.outputs.sql }}
          hasConfiguration: ${{ steps.cR.outputs.config }}
          hasDependencies: ${{ steps.cR.outputs.dependency }}
          additionalText: "extra"
          epic: "epic"
          webhookUri: 18cc2b84.freenetgroup.onmicrosoft.com@emea.teams.ms
          mailTemplate: "B_MS.ftl"
          atlassianToolsVersion: 1.18.0
          

## Parameter
 
name: 'sendMail2'
description: 'Versenden einer Releasebuild-Notification (an MS-Teams)'
inputs:
  component:
    description: der Name der zu erzeugenden Komponente (erforderlich für Auswertung der Komponenten)
    required: true
  componentVersion:
    description: Die Version der erzeugten Kompponente
    required: true
  goingLiveDate:
    description: Das Inbetriebnahmedatum der Komponente (Klartext)
    required: TRUE  
  issueList:
    description: Die Liste der integrierten Issues
    required: true  
  hasSql:
    description:
    required: true
  hasConfiguration:
    description: Config-Anpassungen (true|false)
    required: true
  hasDependencies:
    description: Abhängigkeiten (true|false)
    required: true
  additionalText:
    description: Extra-Text
    required: true
  epic:
    description: Das EPIC der Komponente
    required: true
  webhookUri:
    description: Die MS-Teams-Zieladresse
    required: true
  mailTemplate:
    description: Das Mail-Template-File
    required: true
  atlassianToolsVersion:
    description: die Version der organisationsinternen AtlassianDeveloperTools (separates Repository)
    required: true
```