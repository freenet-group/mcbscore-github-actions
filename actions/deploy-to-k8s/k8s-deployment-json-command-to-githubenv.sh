#!/usr/bin/env bash
# Liest kubernetes-deployment-JSON (z.B. gemergte Ausgabe von k8s-deployment-json-to-githubenv.sh)
# von Stdin und ermittelt die Kommandozeile für den java-Start und gibt es im $GITHUB_ENV-Format
# nach Stdout aus.

set -o errexit

: ${K8S_INTERNAL_PORT:?}	# Pflichtvariablen prüfen

cmd=$(jq --slurp --raw-output --arg port "$K8S_INTERNAL_PORT" '
  # Konvertiert einen Eintrag in javaOptions oder javaArgs zum Kommandozeilenargument in einem Shell-Befehl.
  def toCommandArg:
	# String: literal (braucht also Shell-Quoting)
	if (.|type) != "object" then
	  (.|@sh)
	# Objekt { "type": "LITERAL", "value": "…" } ist nur eine fancy Schreibweise für String "…"
	elif .type == "LITERAL" then
	  (.value|@sh)
	# Objekt { "type": "SHELL", "value": "…" }: $ evaluieren, aber nicht an Whitespace
	# in mehrere Argumente zerfallen lassen. Also in "…".
	elif .type == "SHELL" then
	  ("\"" + .value + "\"")
	else
	  ("invalid type " + .type + " in " + (.|tostring)) | halt_error
	end;

	add
	| [
		"java",
		"-Dserver.port=" + $port,
		(.javaOptions // [] | map(toCommandArg)[]),
		"-jar",
		(.jarName //("jarName fehlt"|halt_error)) + ".jar",
		(.javaArgs // [] | map(toCommandArg)[])
	]
	| join(" ")
')
printf 'JAVA_COMMAND=%s\n' "$cmd"
