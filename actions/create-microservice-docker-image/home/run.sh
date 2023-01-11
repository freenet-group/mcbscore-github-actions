#!/usr/bin/env bash
appInstance=$(hostname)
heapDumpDir=dumps/${SERVICE_NAME}
heapDumpPath=${heapDumpDir}/${appInstance}_${SERVICE_VERSION}_$(date +"%Y-%m-%dT%H%M%S").hprof

mkdir -p -- "$heapDumpDir"

# Paranoia: Falls $heapDumpPath existiert, auch noch PID ergänzen (vor dem Punkt).
# (Falls die auch existiert, wird Java nichts schreiben.)
heapDumpPath=$(f="$heapDumpPath" pid=$$ flock -- "$heapDumpDir" bash -c '
	if [ -e "$f" ]; then
		printf "%s\\n" "${f%.*}_${pid}.${f##*.}"
	else
		printf "%s\\n" "$f"
	fi
')

exec java \
	 -XX:+ExitOnOutOfMemoryError -XX:+HeapDumpOnOutOfMemoryError "-XX:HeapDumpPath=$heapDumpPath" \
	 ${JAVA_OPTS} ${SPRING_OPTS} \
	 -jar "${SERVICE_NAME}.jar"
