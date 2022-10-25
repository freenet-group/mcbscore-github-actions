# set-fix-version

GitHub-Action zum Setzen der FixVersion an den am Releasebuild beteiligten JIRA-Issues

## Parameter:
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
    description: die mit $COMPONENT zusammen zu setzende Versionskennung (zuvor ermittelt mit "createVersion"
    required: true  
  ### issueList
    description: Liste der beteiligten JIRA-Issues als String (blank-sep.)
    required: true
  ### atlassianToolsVersion
    description: die Version der organisationsinternen AtlassianDeveloperTools (separates Repository)  
    required: false  
  ### logLevel
    description: Das LogLevel der innerhalb der Action ablaufenden AtlassianDeveloperTools  
    required: true  

---

## Ergebnisse:
Die für das aktuelle Releasebuild relevanten JIRA-Issues werden, sofern die Komponente korreliert, um die aus COMPONENT und VERSION bestehende VeLösungsversion ergänzt

---

## Voraussetzungen:
Vor dem Aufruf der Action müssen folgende Rahmenbedingungen geschaffen werden:
1. Checkout des Repository der zu bearbeitenden Komponente
2. Checkout der organisationsinternen Actions in das Unterverzeichnis "mcbscore/github"
3. JDK-Setup