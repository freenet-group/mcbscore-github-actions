#!/bin/bash
# Download v. Artefakten aus GitHub-Packages
# ben. Umgebungsvariablen:
# ARTIFACT_ID, GROUP_ID, ORGANISATION, VERSION, TARGET_PATH, GITHUB_USER, TOKEN
# benutzt sed, Maven

set -e
# settings.xml anpassen mit Parametern
echo "konfiguriere settings.xml..."
sed -iBAK "s/{ARTIFACT_ID}/$ARTIFACT_ID/g;s/{TOKEN}/$TOKEN/g;s/{GITHUB_USER}/$GITHUB_USER/g;s/{ORGANISATION}/$ORGANISATION/g" settings.xml
# Artefakt herunterladen mit Maven
echo "lade Artefakt über mvn herunter..."
mvn --settings ./settings.xml dependency:copy -Dartifact="$GROUP_ID:$ARTIFACT_ID:$VERSION" -DoutputDirectory=./ -Dmdep.stripVersion=true
# heruntergeladenes Artefakt verschieben
mv $ARTIFACT_ID.jar $TARGET_PATH/$artifactId-$version.jar

