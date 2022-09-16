# create-sonar-issue

GitHub-Action zur Erzeugung eines JIRA-Issues zur Anpassung einer unzureichenden Testabdeckung

### jiraUrl  
    description: Organisationsinterne URL des angebundenen JIRA-Systems
    required: true
### jiraCredentials
    description: Organisationsinterne Credentials (user:password) des angebundenen JIRA-Systems
    required: true
### jiraProject
    description: Das JIRA Projekt, in dem das Ticket erstellt werden soll
    required: true
### issueType
    description: Die Art des Tickets
    required: false
    default: Fehler
### assignee
    description: Der Bearbeiter des Tickets (MCBS Core)
    required: false
    default: jiraitababen
### watchers
    description: Benutzer, die bei Änderungen am Ticket benachrichtigt werden sollen
    required: false
    default: "bmoeller,maiyya"
### component
    description: der Name der zu erzeugenden Komponente (erforderlich für Auswertung der Komponenten)
    required: true
### componentVersion
    description: die zur Komponente gehörende Version
    required: true
### coverageLimit
    description: der Sonar-Schwellwert
    required: true
### coverage
    description: die tatsächliche Abdeckung
    required: true  
### requirementId
    description: die Anforderungs-Id
    required: true
    default: PRIOMD-6859
### atlassianToolsVersion
    description: die Version der organisationsinternen AtlassianDeveloperTools (separates Repository)
    required: true
### logLevel
    description: Das LogLevel der innerhalb der Action ablaufenden AtlassianDeveloperTools
    required: false
    default: info

## Voraussetzungen:

SourceCode-Repository ausgecheckt
Actions ausgecheckt
Coverage der Komponente wurde zuvor ermittelt


## Aufruf:

      # Coverage auswerten und ggf. Issue erzeugen
      - name: checkCoverage and create Issue
        if: ${{ (env.COVERAGE_APP != '') && (steps.fetch-coverage.outputs.coverage < env.COVERAGE_LIMIT) && (env.COVERAGE_FAIL == 'TRUE') }}
        uses: ./mcbscore/github/actions/create-sonar-issue
        with:
          jiraUrl: ${{ env.JIRA_URL }}
          jiraCredentials: ${{ env.MCBSTEST_CREDENTIALS }}
          jiraProject: ${{ env.JIRA_PROJECT }}
          component: ${{ env.JIRA_COMPONENT }}
          componentVersion: ${{ github.event.inputs.releaseVersion }}
          coverageLimit: ${{ env.COVERAGE_LIMIT }}
          coverage: ${{ steps.fetch-coverage.outputs.coverage }}
          atlassianToolsVersion: ${{ env.ATLASSIAN_DEVELOPER_TOOLS_VERSION }}
