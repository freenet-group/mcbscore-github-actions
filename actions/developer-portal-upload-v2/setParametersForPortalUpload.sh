#!/bin/bash
# TODO: Umsetzung oder Entfernung mit ABRMS-5324

set -e

function evalValue() {
  local value="$1"

  # printf statt echo um zu verhindern, dass ein Teil von $value als echo-Option interpretiert wird
  function echo-safe() { printf ' %s' "$@" | cut --characters=2-; }
  eval echo-safe "$value"
}

# Liest Properties-Dateien und setzt ein assoziatives Array mit den Werten daraus.
# Parameter:
# - $1: Variablenname (z.B. DEPLOYMENT_PROPS); muss vorher vom Aufrufer als assoziatives Array deklariert werden
# - $2, ...: Property-Datei-Name(n); spätere überschreiben ehere
# => Setzt z.B.: DEPLOYMENT_PROPS['api.name']='customer'
function readPropertiesIntoMap() {
	local jsCode tmpFile
	tmpFile=$(mktemp)
	jsCode=$(cat <<'EOF'
		argsList = new java.util.LinkedList(java.util.Arrays.asList(arguments));
		varName = argsList.removeFirst();
		p = new java.util.Properties();
		argsList.forEach(function(filename) {
			file = new java.io.File(filename);
			if (!file.exists()) { return }

			err.println("lese " + filename);
			// Properties.load dokumentiert nicht die Überschreibe-Prio.
			// => Sicherheitshalber in separate Properties laden
			pTemp = new java.util.Properties();
			inputStream = new java.io.FileInputStream(file);
			try { pTemp.load(inputStream); } finally { inputStream.close(); }
			p.putAll(pTemp); // ist eigentlich auch nicht sicher, weil pTemp's Defaults verloren gehen
		});
		p.forEach(function(k,v) {
			// Bash-Code wird in dieser Form ausgegeben: z.B.
			// DEPLOYMENT_PROPS['root.dir']='/home/xy'
			// Quoting von einfachen Anführungszeichen (angenommen Key "root'dir", Wert "/ho'me/xy"):
			// DEPLOYMENT_PROPS['root'\''dir']=['/ho'\''me/xy']
			// (d.h. ein ' zum String beenden, ein \' für literalen ', ein ' zu String fortsetzen).
			// Backslash doppeln für JavaScript-String und nochmal gegen replaceAll-Interpretation.
			kq = k.replaceAll("'", "'\\\\''");
			vq = v.replaceAll("'", "'\\\\''");

			out.format("%s['%s']='%s'\n", varName, kq, vq);
		});
EOF
	)
	jrunscript -e "$jsCode" "$@" > "$tmpFile"
	cat -- "$tmpFile"
	source -- "$tmpFile"
	rm -f -- "$tmpFile"
}

environment=$STAGE
echo "environment: $environment"

# Einlesen der Backend Version
componentVersion=$COMPONENT_VERSION
echo "componentVersion: $componentVersion"

# Auslesen des Build Timestamps
buildTimestamp=$RELEASE_CREATED_AT
echo "buildTimestamp: $buildTimestamp"

declare -A DEPLOYMENT_PROPS
: ${GENERIC_DEPLOYMENT_FILE:=./$COMPONENT_CONFIG_PATH/properties/$COMPONENT/deployment.properties}
: ${DEPLOYMENT_FILE:=./$COMPONENT_CONFIG_PATH/properties/$COMPONENT/deployment-$environment.properties}
readPropertiesIntoMap DEPLOYMENT_PROPS "$GENERIC_DEPLOYMENT_FILE" "$DEPLOYMENT_FILE"

# ${deployment.api.name}
apiName=$(evalValue "${DEPLOYMENT_PROPS[api.name]}")
echo "apiName: $apiName"

# ${deployment.api.portal.uri}
portalURI=$(evalValue "${DEPLOYMENT_PROPS[api.portal.uri]}")
echo "portalURI: $portalURI"

# ${deployment.public.api.ids}
publicApiVersions=$(evalValue "${DEPLOYMENT_PROPS[public.api.ids]}")
echo "publicApiVersions: $publicApiVersions"

# ${deployment.system.api.ids}
systemApiVersions=$(evalValue "${DEPLOYMENT_PROPS[system.api.ids]}")
echo "systemApiVersions: $systemApiVersions"

# Wenn DEV, dann API Version suffix = -SNAPSHOT-${bamboo.buildNumber}
# TODO: Umbau nach Klärung der Versionierung
apiVersionSuffix=$(date -d "${buildTimestamp}" +%Y%m%d%H%M%S)
echo "apiVersionSuffix: $apiVersionSuffix"

# Setzen des Upload Headers
header="content-type=multipart/form-data"

#Werte nicht printen, da die Secrets nicht ins buildlog verfügbar sein sollen.
# cliend_id für Authentifizierung gegen den oidc/STS
cliendId=$CLIENT_ID (AWS-Parameter)
# client_secret für Authentifizierung gegen den oidc/STS
clientSecret=$CLIENT_SECRET (AWS-Parameter)

#Authentifizierung gegen den oidc/STS (AWS-Parameter)
authorizationURI=$AUTHORIZATION_URI

#in v2 muss sich zunächst ein token zum authentifizieren geholt werden.
echo "Starte authentifizierung"
curlResult=$(curl -sw %{http_code} -v  -X POST -H "User-Agent: freenet-group/gh-action" -d "client_id=${cliendId}&client_secret=${clientSecret}&grant_type=client_credentials" ${authorizationURI})

#ergebniss behandeln
echo "curlResult: $curlResult"
statusCode="${curlResult:${#curlResult}-3}"
echo "statusCode: $statusCode"
responseJson="${curlResult:0:${#curlResult}-3}"
echo "responseJson: $responseJson"

if [[ "$statusCode" == "200" ]]; then
	#accessToken speichern
	accessToken=$(node -pe 'JSON.parse(process.argv[1]).access_token' "$responseJson")
	echo "Authentifizierung war erfolgreich"
	
else
	errorMessage=$(node -pe 'JSON.parse(process.argv[1]).message' "$responseJson")
	# Fehler beim Upload
	echo "Fehler bei Authentifizierung: $errorMessage"
	exit 1
fi


# system-api
echo ""
echo "Upload der SYSTEM APIS"

for systemApiVersion in $systemApiVersions; do

	versionAndIdArray=(${systemApiVersion//:/ })

	apiVersion=${versionAndIdArray[0]}
	echo "apiVersion: ${apiVersion}"
	systemApiId=${versionAndIdArray[1]}
	echo "systemApiId: $systemApiId"

	# Setzen des Pfades der System API
	systemApiPath=./apiDoc/${apiName}_system_${apiVersion}_${environment}.yaml
	echo "systemApiPath: $systemApiPath"

	if [ -f ./apiDoc/blacklist ] && grep -q "${apiName}_system_${apiVersion}_${environment}.yaml" ./apiDoc/blacklist ; then
		echo "${apiName}_system_${apiVersion}_${environment}.yaml ist auf der Blacklist"
	else
		# Setzen des Patch Levels der API
		sed -i s/{patchLevel}/${apiVersionSuffix}/g $systemApiPath

		# Curl Parameter für System API
		systemFormString="metadata={\"apiId\":\"$systemApiId\",\"backendVersion\":\"$componentVersion\",\"environment\":\"$environment\",\"categories\":[\"system-api\"]}"
		systemContent="content=@${systemApiPath}"

		# upload system-api
		#upload gegen v2
		echo "curl -sw %{http_code} -k -v -X POST -H "Authorization: Bearer ***" -H Expect: -H ${header} --form-string ${systemFormString} -F ${systemContent} ${portalURI}"
		curlResult=$(curl -sw "%{http_code}" -k -v -X POST -H "Authorization: Bearer ${accessToken}" -H "Expect:" -H "${header}" --form-string "${systemFormString}" -F "${systemContent}" "${portalURI}")

		
		echo "curlResult: $curlResult"
		statusCode="${curlResult:${#curlResult}-3}"
		echo "statusCode: $statusCode"
		responseJson="${curlResult:0:${#curlResult}-3}"
		echo "responseJson: $responseJson"

		if [[ "$statusCode" == "200" ]]; then
			echo "Upload der System API erfolgreich"
		else
			errorMessage=$(node -pe 'JSON.parse(process.argv[1]).message' "$responseJson")
			echo "errorMessage: $errorMessage"

			if [ "$statusCode" == "400" -a "$errorMessage" == "The swagger-verison did not change" ]; then
				echo "Kein Upload der System API, da Yaml Version unverändert."
			elif [ "$statusCode" == "400" -a "$errorMessage" == "The swagger-version did not change" ]; then
				echo "Kein Upload der System API, da Yaml Version unverändert."
			else
				# Fehler beim Upload
				echo "Upload Fehler: $errorMessage"
				exit 1
			fi
		fi
	fi

done

# public-api
echo ""
echo "Upload der PUBLIC APIS"

for publicApiVersion in $publicApiVersions; do

	versionAndIdArray=(${publicApiVersion//:/ })
	
	apiVersion=${versionAndIdArray[0]}
	echo "apiVersion: ${apiVersion}"
	publicApiId=${versionAndIdArray[1]}
	echo "publicApiId: $publicApiId"

	# Setzen des Pfades der Public API
	publicApiPath=./apiDoc/${apiName}_client_${apiVersion}_${environment}.yaml
	echo "publicApiPath: $publicApiPath"

	if [ -f ./apiDoc/blacklist ] && grep -q "${apiName}_client_${apiVersion}_${environment}.yaml" ./apiDoc/blacklist ; then
		echo "${apiName}client_${apiVersion}_${environment}.yaml ist auf der Blacklist"
	else
		# Setzen des Patch Levels der API
		sed -i s/{patchLevel}/${apiVersionSuffix}/g $publicApiPath

		# Curl Parameter für Public API
		publicFormString="metadata={\"apiId\":\"$publicApiId\",\"backendVersion\":\"$componentVersion\",\"environment\":\"$environment\",\"categories\":[\"public-api\"]}"
		publicContent="content=@${publicApiPath}"

		# upload public-api		
		echo "curl -sw %{http_code} -k -v -X POST -H "Authorization: Bearer ***" -H Expect: -H ${header} --form-string ${systemFormString} -F ${systemContent} ${portalURI}"
		curlResult=$(curl -sw "%{http_code}" -k -v -X POST -H "Authorization: Bearer ${accessToken}" -H "Expect:" -H "${header}" --form-string "${publicFormString}" -F "${publicContent}" "${portalURI}")

		
		echo "curlResult: $curlResult"
		statusCode="${curlResult:${#curlResult}-3}"
		echo "statusCode: $statusCode"
		responseJson="${curlResult:0:${#curlResult}-3}"
		echo "responseJson: $responseJson"

		if [[ "$statusCode" == "200" ]]; then
			echo "Upload der Public API erfolgreich"
			exit 0
		else
			errorMessage=$(node -pe 'JSON.parse(process.argv[1]).message' "$responseJson")
			echo "errorMessage: $errorMessage"

			if [ "$statusCode" == "400" -a "$errorMessage" == "The swagger-verison did not change" ]; then
				echo "Kein Upload der Public API, da Yaml Version unverändert."
				exit 0
			elif [ "$statusCode" == "400" -a "$errorMessage" == "The swagger-version did not change" ]; then
				echo "Kein Upload der Public API, da Yaml Version unverändert."
				exit 0
			else
				# Fehler beim Upload
				echo "Upload Fehler: $errorMessage"
				exit 1
			fi
		fi
	fi
	
done