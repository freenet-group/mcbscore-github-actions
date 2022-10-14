#!/bin/bash

set -e
source "$(dirname -- "$BASH_SOURCE")/../common/utils.sh"

environment=$STAGE
echo "environment: $environment"

# Einlesen der Backend Version
componentVersion=$COMPONENT_VERSION
echo "componentVersion: $componentVersion"

# Auslesen des Build Timestamps
buildTimestamp=$RELEASE_CREATED_AT
echo "buildTimestamp: $buildTimestamp"

declare -A DEPLOYMENT_PROPS
: ${GENERIC_DEPLOYMENT_FILE:=./properties/$COMPONENT/deployment.properties}
: ${DEPLOYMENT_FILE:=./properties/$COMPONENT/deployment-$environment.properties}
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
# cliend_id für v2
cliendId=$CLIENT_ID
# client_secret für v2
clientSecret=$CLIENT_SECRET

#Authentifizierung gegen den oidc
authorizationURI="https://identity.mobilcom-debitel.de/v2/oidc/token"

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
	echo "Authenzifizierung war erfolgreich"
	
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