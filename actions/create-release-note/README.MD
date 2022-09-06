# create-release-note
![MCBS](../mcbs.png)   
GitHub-Action zur Auswertung des Repositories, um im Anschluss eine Jira-Issue-Liste für Releasenotes  
sowie eine neu zu erzeugende Release-Version zu ermitteln ...

## Parameter:
  ### jiraUrl
    description: Organisationsinterne URL des angebundenen JIRA-Systems  
    required: true
  ### jiraCredentials  
    description: Organisationsinterne Credentials (user:password) des angebundenen JIRA-Systems  
    required: true 
  ### issueList
    description: Liste der beteiligten JIRA-Issues
    required: true
  ### sonarUrl
    description: Organisationsinterne URL des angebundenen SONAR-Systems
    required: true
  ### repositoryName
    description: der Name des zugehörigen Repositories
    required: true
  ### component    
    description: der Name der zu erzeugenden Komponente (erforderlich für Auswertung der Komponenten)  
    required: true
  ### componentVersion
    description: die zur Komponente gehörende Version
    required: true
  ### releaseUrl
    description: Die Downloadadresse für das Release
    required: true
  ### junitResultUrl
    description: Die Downloadadresse für das JUnit-Testergebnis
    required: true
  ### cucumberResultUrl
    description: Die Downloadadresse für das Cucumber-Testergebnis
    required: true
  ### atlassianToolsVersion  
    description: die Version der organisationsinternen AtlassianDeveloperTools (separates Repository)  
    required: true  
  ### epic
    description: Das EPIC als Releaseklammer
    required: false
    default: META-170

---

## Ergebnisse:
Zu den zu verarbeitenden Informationen werden Property-Files angelegt, die auch an anderer Stelle verwendbar sind.

---

## Voraussetzungen:
Vor dem Aufruf der Action müssen folgende Rahmenbedingungen geschaffen werden:
1. Checkout des Repository der zu bearbeitenden Komponente
2. Checkout der organisationsinternen Actions in das Unterverzeichnis "mcbscore/github"
3. Checkout des zum Repository gehörenden WIKI-Repositories in das Unterverzeichnis "markdown"
4. JDK-Setup
 
---

## Ablauf:
1. Es werden nacheinander Java-Aufrufe getätigt, um:
  - Dependencies zu ermitteln (1 Property-File mit true||false , 1 Property-File mit Dependency-Content gem. JIRA-Issue)
  - die Existenz der Komponente "SQL-Update" abzufragen (1 Property-File mit true||false
  - die Existenz der Komponente "ms-configuration" abzufragen (1 Property-File mit true||false)
  - die Testabdeckung dieser Komponente aus Sonar auszulesen (1 Property-File mit coverage)
2. Es wird eine MarkDown-Datei im Unterverzeichnis "markdown" erzeugt und beschrieben:
  - SQL
  - Config
  - Dependencies
  - Coverage
  - (Testresults)
  - Implementierte Inhalte gem issue_infos
3. WIKI-Repository wird mit commit abgeschlossen