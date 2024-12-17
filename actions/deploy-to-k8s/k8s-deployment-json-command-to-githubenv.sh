#!/usr/bin/env bash
# Liest kubernetes-deployment-JSON (z.B. gemergte Ausgabe von k8s-deployment-json-to-githubenv.sh)
# von Stdin und ermittelt die Kommandozeile für den java-Start und gibt es im $GITHUB_ENV-Format
# nach Stdout aus.

set -o errexit -o pipefail

: ${GITHUB_CONTEXT_JSON:?} ${HELM_CHART_DIR:?}	# Pflichtvariablen prüfen

json=$(cat)	#weil wir Stdin mehrfach lesen wollen, in Variable speichern

# javaOptions und javaArgs Werte ermitteln, die außerhalb vom Haupt-jq-Kommando evaluiert werden müssen:
# Beispiel javaOptions Eintrag: "-Dmd.kubernetes.cluster=": {"type": "JQ", "value": ".config.cluster"}.
# Unterstützte Typen: "JQ", "HELM_VALUE", "GITHUB_INPUT".
#
# Ausgabe-Zeilenformat (Tab-separiert): Map-Schlüssel, Typ, (zu evaluierender) Wert.
# Map-Schlüssel ist das ganze {"type": …, "value": …} Objekt als JSON-String und dann Base64-kodiert.
# Als JSON-String sollte eigentlich reichen, aber für Eintrag
#	"-Dspring.profiles.active=": {
#		"type": "JQ",
#		"value": "[.inputs.environment, \"kube\", \"kube\" + .inputs.environment] | join(\",\")"
#	},
# tat es das irgendwie nicht. Deshalb zusätzlich Base64.
substitutions=$(jq --raw-output '
	(.javaOptions + .javaArgs)
	| to_entries[]
	| select(
		((.value | type) == "object")
		and (.value.type as $vt | $vt == "JQ" or $vt == "GITHUB_INPUT" or $vt == "HELM_VALUE"))
	| .value
	| [(tojson | @base64), .type, .value] | @tsv' <<<"$json")

# JSON-Map aufbauen mit o.g. Schlüsseln und den evaluierten Werten:
substMapJson='{}'
substInputJson=$(jq --null-input --compact-output --argjson g "$GITHUB_CONTEXT_JSON" --argjson c "$json" '{"config": $c, "github": $g}')
while IFS=$'\t' read -r key type valueExpr; do
	case "$type" in
	(HELM_VALUE)
		value=$(helm show values --jsonpath "$valueExpr" "$HELM_CHART_DIR");;
	(JQ)
		value=$(jq --raw-output "($valueExpr)" <<<"$substInputJson");;
	(GITHUB_INPUT)
		value=$(jq --raw-output ".event.inputs.$valueExpr" <<<"$GITHUB_CONTEXT_JSON");;
	(*)
		echo "unbekannter Wertetyp $type in $(base64 --decode <<<"$key")" >&2; exit 1;;
	esac
	printf 'Konfig-Ersetzung: %s "%s": "%s"\n' "$type" "$valueExpr" "$value" >&2
	substMapJson=$(jq --null-input --compact-output --argjson m "$substMapJson" --arg k "$key" --arg v "$value" '$m + {$k: $v}')
done <<<"$substitutions"

# Haupt-jq-Kommando: java-Kommando ausgeben
jqCommand='
	def applySubst:
		to_entries
		| map(
			$subst[(.value | tojson | @base64)] as $substValue
			| (if $substValue == null then . else {"key": .key, "value": $substValue} end)
		)
		| from_entries;

	# Konvertiert einen Eintrag mit skalarem Wert (in javaOptions oder javaArgs), hier gegeben als
	# z.B. { "key": "-Xmx", "value": "800m" } zu einem Kommandozeilenargument in einem Shell-Befehl.
	# Unterstützte .value:
	# - String: literaler String
	# - Objekt der Form {"type": "LITERAL", "value": "…"}: literaler String
	# - Objekt der Form {"type": "SHELL", "value": "…"}: String mit Shellkonstrukten
	# - beliebiges Objekt, dessen JSON-Darstellung ein Schlüssel in $subst ist ⇒ wird durch den zug. Wert ersetzt
	#   (also in Kombination mit der Vorarbeit Formen
	#   - {"type": "HELM_VALUE", "value": "…"},
	#   - {"type": "JQ", "value": "…"},
	#   - {"type": "GITHUB_INPUT", "value": "…"}
	def toCommandArg:
		# String: literal (braucht also Shell-Quoting)
		if (.value | type) == "string" then
		  ((.key + .value) | @sh)
		elif (.value | type) == "object" then
			if .value.type == "LITERAL" then
				# Objekt { "type": "LITERAL", "value": "…" } ist nur eine fancy Schreibweise für String "…"
				((.key + .value) | @sh)
			elif .value.type == "SHELL" then
				# Objekt { "type": "SHELL", "value": "…" }: $ evaluieren, aber nicht an Whitespace
				# in mehrere Argumente zerfallen lassen. Also Schlüssel quoten, Wert nur in "…".
				((.key | @sh) + "\"" + .value.value + "\"")
			#else
			#	("ungültiger .value.type " + .value.type + " in " + (.key|tostring) + " → " + (.|tostring)) | halt_error
			end
		else
		  ("ungültiger value Typ " + (.value | type) + " in " + (.key|tostring) + " → " + (.|tostring)) | halt_error
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
  if .jarName == null then
    ""
  else
	  [
	    "java",
	    ((.javaOptions // {}) | applySubst | objectToCommandArgs),
	  	"-jar",
	  	.jarName + ".jar",
	  	((.javaArgs // {}) | applySubst | objectToCommandArgs)
	  ]
	  | flatten
	  | join(" ")
  end
'
cmd=$(jq --argjson subst "$substMapJson" --raw-output "$jqCommand" <<<"$json")
printf 'JAVA_COMMAND=%s\n' "$cmd"
