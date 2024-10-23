#!/usr/bin/env bash
# Liest kubernetes-deployment-JSON (z.B. gemergte Ausgabe von k8s-deployment-json-to-githubenv.sh)
# von Stdin und ermittelt die Kommandozeile für den java-Start und gibt es im $GITHUB_ENV-Format
# nach Stdout aus.

set -o errexit

: ${ENVIRONMENT:?} ${K8S_WORKDIR:?} ${K8S_INTERNAL_PORT:?}	# Pflichtvariablen prüfen

jqCommand='
	# Konvertiert einen Eintrag mit skalarem Wert in javaOptions oder javaArgs, hier gegeben als
	# z.B. { "key": "-Xmx", "value": "800m" } zu einem Kommandozeilenargument in einem Shell-Befehl.
	# Unterstützte .value Typen:
	# - String: literaler String
	# - Objekt der Form { "type": "LITERAL", "value": "…" }: literaler String
	# - Objekt der Form { "type": "SHELL", "value": "…" }: String mit Shellkonstrukten
	def toCommandArg:
		# String: literal (braucht also Shell-Quoting)
		if (.value|type) == "string" then
		  ((.key + .value) | @sh)
		# Objekt { "type": "LITERAL", "value": "…" } ist nur eine fancy Schreibweise für String "…"
		elif .value.type == "LITERAL" then
		  ((.key + .value) | @sh)
		# Objekt { "type": "SHELL", "value": "…" }: $ evaluieren, aber nicht an Whitespace
		# in mehrere Argumente zerfallen lassen. Also Schlüssel quoten, Wert nur in "…".
		elif .value.type == "SHELL" then
		  ((.key | @sh) + "\"" + .value.value + "\"")
		else
		  ("invalid value .type " + .value.type + " in " + (.key|tostring) + " → " + (.|tostring)) | halt_error
		end
	;

	# Konvertiert einen Eintrag mit potentiell Array-Wert in javaOptions oder javaArgs, hier gegeben
	# als z.B. { "key": "-x", "value": ["a", "b", "c"] } zu Kommandozeilenargumenten in einem Shell-
	# Befehl.
	# Ruft dazu für jedes Element von .value toCommandArg auf.
	# Unterstützte .value Typen:
	# - null: Kommandozeilenargument unterdrücken
	# - ein Wert, den toCommandArg akzeptiert,
	# - ein Array von Werten, die toCommandArg akzeptiert.
	def toCommandArgs:
		# Wert null: kein Kommandozeilenargument
		if (.value == null) then
			[]
		else
			. as $entry
			| (if ($entry.value | type) == "array" then .value else [.value] end)
			| map(({ "key": $entry.key, "value": .}) | toCommandArg)
		end
	;

	def objectToCommandArgs: to_entries | map(toCommandArgs);

	[
		"java",
		"-Dserver.port=" + $ENV.K8S_INTERNAL_PORT,
		"-Dlogging.config=" + $ENV.K8S_WORKDIR + "/config/logback-kube.xml",
		"-Dmd.kubernetes.cluster=" + .cluster,
		# Spring-Profile z.B. dev, kube, kubedev:
		"-Dspring.profiles.active=" + $ENV.ENVIRONMENT + ",kube,kube" + $ENV.ENVIRONMENT,
		"-Denvironment=" + $ENV.ENVIRONMENT,
		"-Dmd.environment=" + $ENV.ENVIRONMENT,
		if ($ENV.DOMAIN // "") == "" then [] else ["-Dmcbs.domain=" + $ENV.DOMAIN] end,
		((.javaOptions // {}) | objectToCommandArgs),
		"-jar",
		(.jarName // ("jarName fehlt"|halt_error)) + ".jar",
		((.javaArgs // {}) | objectToCommandArgs)
	]
	| flatten
	| join(" ")
'

cmd=$(jq --raw-output "$jqCommand")
printf 'JAVA_COMMAND=%s\n' "$cmd"
