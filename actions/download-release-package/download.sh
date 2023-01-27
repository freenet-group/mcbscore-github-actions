#!/bin/bash
# Download v. Artefakten aus GitHub-Packages
# ben. Umgebungsvariablen:
# ARTIFACT_ID, GROUP_ID, ORGANISATION, VERSION, TARGET_PATH, 
# GITHUB_USER, TOKEN, SUFFIX, CLASSIFIER
# benutzt sed, Maven

set -e
# settings.xml anpassen mit Parametern
echo "konfiguriere settings.xml..."
sed -i "s/{PACKAGE_NAME}/$PACKAGE_NAME/g;s/{TOKEN}/$TOKEN/g;s/{GITHUB_USER}/$GITHUB_USER/g;s/{ORGANISATION}/$ORGANISATION/g" settings.xml
# Artefakt herunterladen mit Maven
echo "lade Artefakt [GROUP_ID:ARTIFACT_ID:VERSION:PACKAGING:CLASSIFIER]=[$GROUP_ID:$ARTIFACT_ID:$VERSION:$SUFFIX:$CLASSIFIER] über mvn herunter..."
if [[ "$CLASSIFIER" != "" ]]; then
    mvn --settings ./settings.xml dependency:copy -Dartifact="$GROUP_ID:$ARTIFACT_ID:$VERSION:$SUFFIX:$CLASSIFIER" -DoutputDirectory=./ -Dmdep.stripVersion=true
    # heruntergeladenes Artefakt verschieben
    mv $ARTIFACT_ID-$CLASSIFIER.$SUFFIX $TARGET_PATH/$ARTIFACT_ID-$VERSION-$CLASSIFIER.$SUFFIX
    ls $TARGET_PATH/$ARTIFACT_ID-$VERSION-$CLASSIFIER.$SUFFIX
else 
    mvn --settings ./settings.xml dependency:copy -Dartifact="$GROUP_ID:$ARTIFACT_ID:$VERSION:$SUFFIX" -DoutputDirectory=./ -Dmdep.stripVersion=true
    # heruntergeladenes Artefakt verschieben
    mv $ARTIFACT_ID.$SUFFIX $TARGET_PATH/$ARTIFACT_ID-$VERSION.$SUFFIX
    ls $TARGET_PATH/$ARTIFACT_ID-$VERSION.$SUFFIX
fi

