#!/usr/bin/env bash

javaOpts=(
  -Xmx2g
  -Dfile.encoding=UTF-8
  "-Dspring.profiles.active=$SPRING_PROFILE"
  # Beim spring.liquibase.drop-first auf Schema metisadm als anderer Benutzer braucht man die Rolle in der URL.
  # Hack: "&options=-c role=…" an default-schema anhängen, weil das der einzige Platzhalter in database.url ist.
  '-Dspring.liquibase.default-schema=metisadm&options=-c%20role=XXXmetisadm'
)

commands=( resetTestData stacktrace )
if "${LOAD_TEST_DATA:=true}"; then
  commands=(
    "${commands[@]}"
    "loadTestData --inputFileName '${REPOSITORY_PATH}/metis-rest/src/main/resources/testDataSetFULL.xml'"
    stacktrace
  )
fi

printf 'Spring-shell commands:\n'; printf '\t%s\n' "${commands[@]}"
printf '%s\n' "${commands[@]}" \
| (set -x; java "${javaOpts[@]}" -jar "$RELEASE_PATH/metis-shell-${COMPONENT_VERSION}.jar") \
| tee metis-shell.out

# Status prüfen (Exceptions führen leider nicht zu Spring Shell Exit Status != 0):
checkMessage() {
  if ! grep -q "$@" -- metis-shell.out; then echo "Erwartete Meldung (grep $@) nicht gefunden" >&2; return 1; fi
}
checkMessage -P '\bresetTestData succeeded\b'
if "$LOAD_TEST_DATA"; then checkMessage -P '\bloadTestData succeeded\b'; fi
