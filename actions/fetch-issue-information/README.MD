# fetch-issue-information
GitHub-Action zur Erzeugung einer CSV-Datei mit Informationen über JIRA-Issues.
Aktuell : "issue;summary;status;components;semanticVersion;keywords;priority;fixVersions;affectedVersions;dependency;"

## Parameter:
  ### jiraUrl:  
    description: Organisationsinterne URL des angebundenen JIRA-Systems  
    required: true
  ### jiraCredentials:  
    description: Organisationsinterne Credentials (user:password) des angebundenen JIRA-Systems  
    required: true  
  ### issueList:
    description: Liste der Issues, für die die Infos bereitzustellen sind
    required: true
  ### atlassianToolsVersion:  
    description: die Version der organisationsinternen AtlassianDeveloperTools (separates Repository)  
    required: true  

---

## Outputs:  
  ### keine

---

## Ergebnisse:
  ### File issue_infos.csv mit:
    "issue;summary;status;components;semanticVersion;keywords;priority;fixVersions;affectedVersions;dependency;"

---

## Voraussetzungen:
Vor dem Aufruf der Action müssen folgende Rahmenbedingungen geschaffen werden:
1. Checkout der organisationsinternen Actions in das Unterverzeichnis "mcbscore/github"
2. JDK-Setup 
