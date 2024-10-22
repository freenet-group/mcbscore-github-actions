#!/usr/bin/env bash
# Kombiniert die kubernetes-deployment*.json Dateien für eine Applikation $COMPONENT, Umgebung
# $ENVIRONMENT und optional Domain $DOMAIN und schreibt das Ergebnis nach Stdout.

set -o errexit

GLOBL_DIR=.

: ${COMPONENT:?} ${ENVIRONMENT:?}	# Pflichtvariablen prüfen

{ # Start Pipe nach jq add

    # Default "secrets" hier beimischen ist bequemer als nachher immer auch den Fall ohne "secrets" zu berücksichtigen.
    printf '{ "secrets": [] }\n'

    # Array von möglichen JSON-Dateien initialisieren; sortiert von niedriger zu hoher Prio.
    # (Das letzte JSON-Objekt gewinnt in jq add.)
    if [ -z "$DOMAIN" -o "$DOMAIN" = '-' ]; then
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
} \
| jq --slurp '
	# Hilfsfunktion zur Abfrage von [k] in Objekt (.)
	# Braucht man, wenn k beim Aufrufer schon ein Funktions-Parameter ist und die Syntax .[k]
	# irgendwie nicht geht.
	def get(k; defaultValue):
		[to_entries[] | select(.key == k)] as $entries
		| if ($entries | length) > 0 then $entries[0].value else defaultValue end
	;

	# Z.B. bei Pipe-Input:
	# - { "x": "x1", "javaOptions": { "a": "1", "b": "2", "c": "3" } }
	# - { "x": "x2", "javaOptions": { "a": null, "b": "20" } }
	# liefert addSubObj("javaOptions") das Ergebnis: { "javaOptions": { "b": "20", "c": "3" } }.
	# Die Einträge mit Schlüssel != k fallen weg.
	def addSubObj(k):
		[
			{
				"key": k,
				"value": [
					map(. | get(k; {}))
					| add
					| to_entries[]
					| select(.value != null)
				] | from_entries
			}
		] | from_entries
	;

	# add auf den ganzen Objekten hat .javaOptions nur von dem letzten mit .javaOptions.
	# Um .javaOptions zu mergen, braucht man noch ein add, angewendet auf alle .javaOptions.
	add + addSubObj("javaOptions") + addSubObj("javaArgs")
'
