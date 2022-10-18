# Skript, das Secrets aus dem AWS ParameterStore ausliest
# und in Dateien ersetzt.
#
# Author: cbolte

echo "Ersetze Parameter..."

# Die Parameter Datei Zeile für Zeile einlesen
while IFS=$'\n' read -r s || [ -n "$s" ]; do

    # Den Parameterwert aus der Zeile extrahieren
    AWS_PARAMETER_KEY=$(echo $s|sed 's/\S*=//g;')

    # Ort der Ersetzung und Platzhalter extrahieren
    LINE_START=$(echo $s|sed 's/=\S*//g;')

    # Datei feststellen
    FILE=$DIRECTORY/$(echo $LINE_START|sed 's/\:\S*//g;')

    # Wenn FILE existiert, weitermachen
    if [ -f "$FILE" ]; then

      # AWS Parameter Wert ermitteln
      AWS_PARAMETER_VALUE=$(aws ssm get-parameter --name $AWS_PARAMETER_KEY --with-decryption | jq -r .Parameter.Value)

      # Platzhalter feststellen
      PLACEHOLDER=$(echo $LINE_START|sed 's/\S*\://g;')

      # Platzhalter in Datei ersetzen
      sed -i "s/$PLACEHOLDER/$AWS_PARAMETER_VALUE/g;" $FILE
    fi

done < "$PARAMETER_FILE"

echo "fertig."