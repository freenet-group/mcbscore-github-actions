# check-single-component
GitHub-Action zur Erzeugung einer CSV-Datei mit Informationen über JIRA-Issues.
Aktuell : "issue;summary;status;components;semanticVersion;keywords;priority;fixVersions;affectedVersions;dependency;"

## Parameter:
  ### jiraUrl
    description: Organisationsinterne URL des angebundenen JIRA-Systems  
    required: true
  ### jiraCredentials
    description: Organisationsinterne Credentials (user:password) des angebundenen JIRA-Systems  
    required: true  
  ### issue
    description: Issue, für die die Info bereitzustellen ist
    required: true
  ### atlassianToolsVersion
    description: die Version der organisationsinternen AtlassianDeveloperTools (separates Repository)  
    required: true  

---

## Ergebnis:
    Property-File singleComponent.properties mit single=true oder single=false
