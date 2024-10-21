#!/usr/bin/env bash
# Liest kubernetes-deployment-JSON (z.B. gemergte Ausgabe von k8s-deployment-json-to-githubenv.sh)
# von Stdin und gibt einige Werte daraus (die die Action braucht) im $GITHUB_ENV-Format nach Stdout
# aus.

set -o errexit

json=$(cat)	#weil wir Stdin mehrfach lesen wollen, in Variable speichern

# einfache Umgebungsvariablen in $GITHUB_ENV-Format ausgeben:
jq --raw-output '
	"K8S_CLUSTER="        + (.cluster       // ("cluster fehlt"       | halt_error)) + "\n" +
	"K8S_ENVIRONMENT="    + (.environment   // ("environment fehlt"   | halt_error)) + "\n" +
	"K8S_NAMESPACE="      + (.namespace     // ("namespace fehlt"     | halt_error)) + "\n" +
	"K8S_COMPONENT_NAME=" + (.componentName // ("ms-" + env["COMPONENT"]))           + "\n" +
	"K8S_VS_HOSTNAME="    + (.virtualService.hostname // "")                         + "\n" +
	"K8S_VS_GATEWAY="     + (.virtualService.gateway  // "")                         + "\n" +
	"HELM_CHART="         + (.helmChart     // "ms")                                 + "\n" +
	""' \
	<<< "$json"

# awsParameterPairs für aws-ssm-getparameters-action ermitteln aus .secrets in $json
# Beispiel:
# $json enthält:
# {
# 	...
# 	"secrets": [
# 		{
# 			"sourceType": "AWS_PARAMETER",
# 			"source": "/config/ms/homer/homer.prince.license",
# 			"targetType": "FILE",
# 			"target": "/usr/lib/prince/license/license.dat"
# 		},
# 		{
# 			"sourceType": "AWS_PARAMETER",
# 			"source": "/config/ms/application/test",
# 			"targetType": "ENV",
# 			"target": "TEST_VAR",
# 			"conversion": "b64enc"
# 		},
# 		{
# 			"sourceType": "SOMETHING_UNSUPPORTED",
# 			"source": "...",
# 			"targetType": "...",
# 			"target": "..."
# 		}
# 	]
# }
# => jq Ergebnis:
#   /config/ms/homer/homer.prince.license=AWS_DYNAMIC_PARAM_NAME1,
#   /config/ms/application/test=AWS_DYNAMIC_PARAM_NAME2,
paramPairs=$(jq -r '
	[ .secrets[] | select(.sourceType == "AWS_PARAMETER") ]
	| foreach .[] as $x (0; . + 1; "\($x.source)=AWS_DYNAMIC_PARAM_NAME\(.),")' \
	<<<"$json")

# Als (mehrzeilige) Variable DYNAMIC_AWS_PARAM_PAIRS im $GITHUB_ENV-Format ausgeben:
printf 'DYNAMIC_AWS_PARAM_PAIRS<<...snip...\n%s\n...snip...\n' "$paramPairs"
