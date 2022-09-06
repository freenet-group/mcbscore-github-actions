# set-issue-comment

GitHub-Action zur Erzeugung einer JIRA-Version und einer JIRA-Component-Version auf Basis einer zuvor ermittelten Versionskennung und einer Komponente ...

## Parameter:
  ### jiraUrl:  
    description: Organisationsinterne URL des angebundenen JIRA-Systems  
    required: true
  ### jiraCredentials:  
    description: Organisationsinterne Credentials (user:password) des angebundenen JIRA-Systems  
    required: true  
  ### comment:
    description: der zu erzeugenden Kommentar
    required: true
  ### issueList:
    description: Liste der Issues , an denen der Kommentar zu setzen ist
    required: true
  ### atlassianToolsVersion:  
    description: die Version der organisationsinternen AtlassianDeveloperTools (separates Repository)  
    required: true  

---

## Outputs:  
  ### keine 

---

## Ergebnisse :
  ### Kommentar an den Issues

---

## Voraussetzungen :
Vor dem Aufruf der Action müssen folgende Rahmenbedingungen geschaffen werden:
1. Checkout des Repository der zu bearbeitenden Komponente
2. Checkout der organisationsinternen Actions in das Unterverzeichnis "mcbscore/github"
3. JDK-Setup
   
   

