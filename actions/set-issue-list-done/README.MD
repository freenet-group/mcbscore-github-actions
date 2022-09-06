# set-issue-list-done

GitHub-Action zum Umsetzen des Status der am Releasebuild beteiligten JIRA-Issues auf "Done"

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

---

## Ergebnisse :
Die Status der für das aktuelle Releasebuild relevanten JIRA-Issues werden auf erledigt gesetzt

---
