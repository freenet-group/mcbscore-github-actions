# jira-configuration

GitHub-Action zur Erzeugung einer JIRA-Version und einer JIRA-Component-Version auf Basis einer zuvor ermittelten Versionskennung und einer Komponente ...

## Parameter:
  ### jiraUrl
    description: Organisationsinterne URL des angebundenen JIRA-Systems  
    required: true
  ### jiraUrl2
    description: Organisationsinterne URL des angebundenen JIRA-Systems  
    required: true
  ### jiraCredentials
    description: Organisationsinterne Credentials (user:password) des angebundenen JIRA-Systems  
    required: true  
  ### jiraProject
    description: der Name des zu bedienenden JIRA-Projekts
    required: true
  ### component
    description: der Name der zu erzeugenden Komponente (erforderlich für Auswertung der Komponenten)
    required: true
  ### componentVersion
    description: die neu einzurichtende Version
    required: true
  ### componentList
    description: Liste der Komponenten, für die eine Component-Version erzeugt weerden soll
    required: true
  ### atlassianToolsVersion
    description: die Version der organisationsinternen AtlassianDeveloperTools (separates Repository)  
    required: true  

---

## Outputs:  
  ### keine

---

## Ergebnisse:
  ### keine

---

## Voraussetzungen:
Vor dem Aufruf der Action müssen folgende Rahmenbedingungen geschaffen werden:
1. Checkout des Repository der zu bearbeitenden Komponente
2. Checkout der organisationsinternen Actions in das Unterverzeichnis "mcbscore/github"
3. JDK-Setup
   
   

