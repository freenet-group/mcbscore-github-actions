# gradle-build

Github-Action zur Durchführung eines Gradle-Builds. Wenn das Property COVERAGE_APP gesetzt ist, wird der Sonarqube-Task gerufen.
Das Default Gradle-Kommando ist: clean build
Für die Branches release und develop wird zusätzlich der publish Task gerufen.

## Parameter:
### gradleCommand
    description: Das Gradle-Kommando
    required: false
    default: clean build
### publishCommand
    description: Das Gradle-Kommando zur Veröffentlichung/Bereitstellung des Artefakts
    required: false
    default: publish
### gradleOptions
    description: Zusätzliche optionale Gradle-Parameter
    required: false
### sonarqubeUrl
    description: Die Sonarqube URL
    required: false
### sonarqubeToken
    description: Das Sonarqube Token
    required: false
### artifactoryUserName
    description: Login für das Artifactory
    required: true
### artifactoryPassword
    description: Passwort für das Artifactory
    required: true

---

## Ergebnisse:

gradlew wurde durchgeführt.

---

## Voraussetzungen:

JAVA muß installiert sein.

---

## Aufruf:

      - id: gradle-build
        name: Gradle Build
        uses: ./mcbscore/github/actions/gradle-build
        with:
          artifactoryUserName: ${{ secrets.MD_ARTIFACTORY_USER }}
          artifactoryPassword: ${{ secrets.MD_ARTIFACTORY_PW }}
