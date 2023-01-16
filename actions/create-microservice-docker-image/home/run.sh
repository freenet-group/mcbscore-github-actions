#!/usr/bin/env bash
set -e
set -o pipefail

appInstance=$(hostname)
heapDumpDir=dumps/${SERVICE_NAME}
heapDumpFile=${appInstance}_${SERVICE_VERSION}_$(date +"%Y-%m-%dT%H%M%S").hprof

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
