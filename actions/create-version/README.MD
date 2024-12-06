# create-version

GitHub-Action zur Auswertung des Repositories, um im Anschluss eine Jira-Issue-Liste für Releasenotes  
sowie eine neu zu erzeugende Release-Version zu ermitteln ...

## Parameter:
  ### jiraUrl
    description: Organisationsinterne URL des angebundenen JIRA-Systems (hinterlegt in secrets) 
    required: true
  ### jiraCredentials
    description: Organisationsinterne Credentials (user:password) des angebundenen JIRA-Systems (hinterlegt in secrets)   
    required: true  
  ### component
    description: der Name der zu erzeugenden Komponente (erforderlich für Auswertung der Komponenten)  
    required: true  
  ### tagPattern
    description: das zu erfüllende Muster für die Suche nach einem Tag im Repository (e.g "*" , "ms-bm.*" ,"[0-9]*") ( glob(7) )
    required: true 
  ### branchName
    description: Der Name des bearbeiteten Branch, um ggf. -SNAPSHOT als Suffix zu setzen
    required: true
  ### versionByComponentList
    description: Erzeugt die Version auf einem anderen Weg (MCBS Spezial). Ist für mcbs-master auf true zu setzen
    required: false
    default: false
  ### atlassianToolsVersion
    description: die Version der organisationsinternen AtlassianDeveloperTools (separates Repository)  
    required: true  

---

## Outputs:  
  ### newVersion:  
    description: die Versionskennung für das nachfolgende Releasebuild  (x.y.z ohne Prefix)
  ### issueList:
    description: Liste der beinhalteten Issues durch Leerzeichen getrennt

---

## Ergebnisse:
1. Die neu zu erzeugende Versionskennung ist zugreifbar unter : ${{ steps.create-version.outputs.newVersion }}
2. Die IssueListe ist zugreifbar unter : ${{ steps.create-version.outputs.issueList }}

---

## Voraussetzungen:
Vor dem Aufruf der Action müssen folgende Rahmenbedingungen geschaffen werden:
1. Checkout des Repository der zu bearbeitenden Komponente mit History und Tags (fetch-depth=0)
2. Checkout der organisationsinternen Actions in das Unterverzeichnis "mcbscore/github"
3. JDK-Setup

---

## Aufruf
      # Repository auschecken unter $GITHUB_WORKSPACE
      - name: checkout Repo
        uses: actions/checkout@v2
        with:
          fetch-depth: 0
          ref: '${{ env.BRANCH }}' 
      
      # Checkout developer-tools (master) in ./devtools
      - name: checkout atldevtools
        uses: actions/checkout@v2
        with:
          repository: 'freenet-group/atldevtools'
          token:   ${{ secrets.GH_REPO_MCBS }}
          path: 'devtools'
      
      # Java / JDK 11 initialisieren
      - name: Setup Java JDK
        uses: actions/setup-java@v4
        with:
          java-version: ${{ env.JAVA_VERSION }}
      
      # Die internen Actions auschecken
      - name: checkout actions-repository
        uses: actions/checkout@v2
        with:
          repository: 'freenet-group/mcbscore_actions'
          token: ${{ secrets.GH_REPO_MCBS }}
          path: 'mcbscore'
          ref: main  
      
      # ##################################################################################
      # Aufruf der Action
      # ##################################################################################
      - name: createVersion
        id: create-version
        uses: ./mcbscore/createVersion
        with:
          JIRA_URL: $JIRA_URL
          JIRA_CREDENTIALS: $JIRA_CREDENTIALS
          COMPONENT: $COMPONENT
          MATCH: $MATCH
          ATLASSIAN_DEVELOPER_TOOLS: $ATLDEVTOOLS
          LOGLEVEL: $LOGLEVEL
          BRANCH_NAME: 'develop' 
      
      # Simple Kontrollausgabe
      - run: |
          echo ${{ steps.create-version.outputs.newVersion }}
          echo "newVersion=${{ steps.create-version.outputs.newVersion }}" >> $GITHUB_ENV
          echo ${{ steps.create-version.outputs.issueList }}
          echo "issueList=${{ steps.create-version.outputs.issueList }}" >> $GITHUB_ENV
