#!/usr/bin/env bash
# Liest kubernetes-deployment-JSON (z.B. gemergte Ausgabe von k8s-deployment-json-to-githubenv.sh)
# von Stdin und ermittelt die Kommandozeile für den java-Start und gibt es im $GITHUB_ENV-Format
# nach Stdout aus.

set -o errexit

: ${K8S_INTERNAL_PORT:?}	# Pflichtvariablen prüfen

cmd=$(jq --raw-output --arg port "$K8S_INTERNAL_PORT" '
	# Konvertiert einen Eintrag in javaOptions oder javaArgs zum Kommandozeilenargument in einem Shell-Befehl.
	def toCommandArg:
		# Wert null: kein Kommandozeilenargument
		if (.value == null) then
			null
		else
			# String: literal (braucht also Shell-Quoting)
			if (.value|type) != "object" then
			  ((.key + .value) | @sh)
			# Objekt { "type": "LITERAL", "value": "…" } ist nur eine fancy Schreibweise für String "…"
			elif .value.type == "LITERAL" then
			  ((.key + .value) | @sh)
			# Objekt { "type": "SHELL", "value": "…" }: $ evaluieren, aber nicht an Whitespace
			# in mehrere Argumente zerfallen lassen. Also Schlüssel quoten, Wert nur in "…".
			elif .value.type == "SHELL" then
			  ((.key | @sh) + "\"" + .value.value + "\"")
			else
			  ("invalid type " + .value.type + " in " + (.key|tostring) + " → " + (.|tostring)) | halt_error
			end
		end
	;

	def objectToCommandArgs:
		to_entries | map(toCommandArg) | select(. != null)
	;

	[
		"java",
		"-Dserver.port=" + $port,
		((.javaOptions // {}) | objectToCommandArgs),
		"-jar",
		(.jarName //("jarName fehlt"|halt_error)) + ".jar",
		((.javaArgs // {}) | objectToCommandArgs)
	]
	| flatten | join(" ")
')
printf 'JAVA_COMMAND=%s\n' "$cmd"
