# Create Backend Issue
![MCBS](../mcbs.png)    
GitHub-Action zur Erzeugung eines JIRA-Issues als Integrationsauftrag für einen erzeugten ZAP-Service in ein ZAP-Backend

## Parameter :
### jiraUrl
    description: Organisationsinterne URL des angebundenen JIRA-Systems
    required: true
### jiraCredentials
    description: Organisationsinterne Credentials (user:password) des angebundenen JIRA-Systems
    required: true
### component
    description: der Name der zu erzeugenden Komponente (erforderlich für Auswertung der Komponenten)
    required: true
### componentVersion
    description: Die erzeugte / zu integrierende Version
    required: true
### epic
    description: Das META-Ticket als Releaseklammer
    required: true
### hasDbChanges
    description: Gibt es DB-Changes (Ja/Nein)
    required: true
### atlassianToolsVersion
    description: die Version der organisationsinternen AtlassianDeveloperTools (separates Repository)
    required: true
### logLevel
    description: Das LogLevel der innerhalb der Action ablaufenden AtlassianDeveloperTools
    required: false
    default: info

---
## Outputs:  
  ### keine 
---
## Ergebnisse :
  ### keine
---
## Voraussetzungen :    
  ### keine