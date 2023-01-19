# set-issue-list-closed

GitHub-Action zum Umsetzen des Status der am Releasebuild beteiligten JIRA-Issues auf "Closed"

## Parameter:
  ### jiraUrl
    description: Organisationsinterne URL des angebundenen JIRA-Systems  
    required: true
  ### jiraCredentials
    description: Organisationsinterne Credentials (user:password) des angebundenen JIRA-Systems  
    required: true  
  ### issueList
    description: Liste der beteiligten JIRA-Issues als String (blank-sep.)
    required: true
  ### atlassianToolsVersion
    description: die Version der organisationsinternen AtlassianDeveloperTools (separates Repository)  
    required: false 
  ### loglevel
    description: das loglevel 
    required: false 
    default: info

---
## Ablauf :
Über die Liste iteriert, wird der Status der einzelnen Issues abgefragt.
Sofern der Status "Entwicklung abgeschlossen" oder "Erledigt" lautet, wird über die Statusübergänge 741:test , 821: testok und 811:close der Issue geschlossen und mit einem entsprechenden Kommentar versehen.
Dieser Mechanismus greift jedoch nur, wenn entweder 1 Komponente , 2 Komponenten (1 * ms-configuration)  oder 2 Komponenten (1 * SQL-Update-Skript) gesetzt sind.

## Ergebnisse :
Die Status der für das aktuelle Releasebuild relevanten JIRA-Issues werden auf erledigt gesetzt

---
