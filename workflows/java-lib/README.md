## Workflows

| Workflow | Beschreibung |
| -------- | ------------ |
| build.yml | Baut das Projekt und führt die Tests aus |
| check_code.yml | Prüft den Code auf UTF und Markierungen. Bei Auffäligkeiten wird ein Kommentar erstellt. |
| check_pull_request.yml | Synchronisiert die Labels mit unserem ABRMS/MCBS-Jira-Projekt. Danach wird auf Pflichtlabels geprüft und gegebenfalls Bambi (API) und DOGS (@freenet-group/abr-ms-gh-deployments) informiert. Auch hier wird bei Auffälligkeiten ein Kommentar erstellt. |
| release.yml | Erstellt ein Release mit Release-Notes und deployt das Release auf DEV |
| postBuild.yml | Verteilt die Release-Information an Jira und Teams |

## Umstellung auf CICD

### Main Branch aktualisieren

* Repo mit Main Branch auschecken
* Develop Branch reinziehen
* Direkt ohne PR committen

### GitHub Repo Einstellungen

* settings:
    * General
        * Default-Branch auf "main" setzen. Im neuen Ablauf wird nach jedem Merge eine neue Version gebaut, somit ist kein "develop"- oder "release"-Branch mehr notwendig
    * Labels
        * Labels sind ein wenig versteckt, können aber unter Issues->Labels gefunden werden
        * Folgende Labels anlegen oder Farben anpassen:
            * release:major mit Color #B60205 ?
            * release:minor mit Color #FBCA04 ?
            * release:patch mit Color #0E8A16 ?
            * renovate mit Color #1D76DB

### Anpassung der distribute.yml

Im Repo mcbscore-github-action muss der Workflow distribute.yml mit einen eigenen Branch angepasst werden:

* Hierzu das Repository in die "java-lib" Gruppe verschieben
    * Branch auf "main" setzen
    * Die Gruppe unter "strategy.matrix.repository.group" muss auf "java-lib" geändert werden
    * Die Workflows müssen gegen den env.DEFAULT_WORKFLOWS geprüft werden und können danach ebenfalls entfernt werden
* Im Anschluss den Workflow unter github->actions->workflows->distribute.yml mit dem Branch und der Gruppe java-lib verteilen

* Unter der spotless Verteilung muss der Branch von "develop" auf "main" geändert werden.

* Nach Abschluss des Umbaus und Tests kann dieser PR ebenfalls gemerged werden.