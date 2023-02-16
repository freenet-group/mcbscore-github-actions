# set-prod-version

GitHub-Action zum Setzen der "Version for Prod" am EPIC sowie zur Anpassung des Status auf "Geliefert"

## Parameter:
  ### jiraUrl
    description: Organisationsinterne URL des angebundenen JIRA-Systems  
    required: true
  ### jiraCredentials
    description: Organisationsinterne Credentials (user:password) des angebundenen JIRA-Systems  
    required: true  
  ### version
    description: Die zu hinterlegende Version
    required: true
  ### issue
    description: Der Identifier des EPIC
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
Einfacher Post auf das custom_Field 10882
Aufruf der Statusänderung auf "41"
## Ergebnisse :
Der Status der Aktualisierung

---
