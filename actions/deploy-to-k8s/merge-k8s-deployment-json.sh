#!/usr/bin/env bash
# Kombiniert die kubernetes-deployment*.json Dateien für eine Applikation $COMPONENT, Umgebung
# $ENVIRONMENT und optional Domain $DOMAIN und schreibt das Ergebnis nach Stdout.

set -o errexit

GLOBL_DIR=environment

: ${COMPONENT:?} ${ENVIRONMENT:?}	# Pflichtvariablen prüfen

{ # Start Pipe nach jq add

    # Default "secrets" hier beimischen ist bequemer als nachher immer auch den Fall ohne "secrets" zu berücksichtigen.
    printf '{ "secrets": [] }\n'

    # Array von möglichen JSON-Dateien initialisieren; sortiert von niedriger zu hoher Prio.
    # (Das letzte JSON-Objekt gewinnt in jq add.)
    if [ "$DOMAIN" = '-' ]; then
        files=(
            "properties/${GLOBL_DIR}/kubernetes-deployment.json"
            "properties/${COMPONENT}/kubernetes-deployment.json"
            "properties/${GLOBL_DIR}/kubernetes-deployment-${ENVIRONMENT}.json"
            "properties/${COMPONENT}/kubernetes-deployment-${ENVIRONMENT}.json"
        )
    else
        files=(
            "properties/${GLOBL_DIR}/kubernetes-deployment.json"
            "properties/${COMPONENT}/kubernetes-deployment.json"
            "properties/${GLOBL_DIR}/kubernetes-deployment-${DOMAIN}.json"
            "properties/${COMPONENT}/kubernetes-deployment-${DOMAIN}.json"
            "properties/${GLOBL_DIR}/kubernetes-deployment-${ENVIRONMENT}.json"
            "properties/${COMPONENT}/kubernetes-deployment-${ENVIRONMENT}.json"
            "properties/${GLOBL_DIR}/kubernetes-deployment-${DOMAIN}-${ENVIRONMENT}.json"
            "properties/${COMPONENT}/kubernetes-deployment-${DOMAIN}-${ENVIRONMENT}.json"
        )
    fi

    for f in "${files[@]}"; do
        if [ -e "$f" ]; then
            printf -- '🗸%s existiert.\n' "$f" >&2
            cat -- "$f"
        else
            printf -- '(%s existiert nicht.)\n' "$f" >&2
        fi
    done
} | jq --slurp add
