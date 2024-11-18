#!/usr/bin/env bash

################################################################################
# ACHTUNG: Dieses Skript wird, so wie wir jetzt in Kubernetes deployen
# [https://freenet-group.atlassian.net/browse/ABRMS-6342], nicht mehr benutzt.
# Da ein Docker Image aber ein zumindest funktionierendes CMD haben sollte
# (auch wenn uns dieses nicht mehr flexibel genug ist), bleibt es bestehen.
################################################################################

set -e
set -o pipefail

appInstance=$(hostname)
heapDumpDir=${HEAPDUMP_DIR:-dumps/${SERVICE_NAME}}
heapDumpFile=$(date +"%Y-%m-%dT%H%M%S")_${SERVICE_VERSION}_${appInstance}.hprof

# (Per NFS gemountetes) Oberverzeichnis könnte readonly sein (=> mkdir scheitert)
# oder Verzeichnis selbst schon existieren aber readonly (=> test -w scheitert).
# In beiden Fällen Fallback auf /tmp.
mkdir -p -- "$heapDumpDir" && test -w "$heapDumpDir" || {
	echo "WARN: $heapDumpDir nicht schreibbar, Fallback /tmp" >&2
	heapDumpDir=/tmp
}
# Paranoia: Falls $heapDumpFile existiert, auch noch PID ergänzen (vor dem Punkt).
# (Falls die auch existiert, wird Java nichts schreiben.)
heapDumpFile=$(cd -- "$heapDumpDir" && f="$heapDumpFile" pid=$$ flock -- . bash -c '
	if [ -e "$f" ]; then
		printf "%s\\n" "${f%.*}_${pid}.${f##*.}"
	else
		printf "%s\\n" "$f"
	fi
')

exec java \
	 -XX:+ExitOnOutOfMemoryError -XX:+HeapDumpOnOutOfMemoryError "-XX:HeapDumpPath=$heapDumpDir/$heapDumpFile" \
	 ${JAVA_OPTS} ${SPRING_OPTS} \
	 -jar "${SERVICE_NAME}.jar"
