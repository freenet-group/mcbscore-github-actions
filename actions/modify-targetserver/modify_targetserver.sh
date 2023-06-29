# Skript zum Ändern/Hinzufügen eines Upstreams
# in der targetserver.conf - Datei des nginx
# benötigte Parameter:
# 1: SERVICE (aus properties, Beispiel "=CONTENTPROVIDER")
# 2: STAGE (aus deployment, Beispiel "DEV")
# 3: FILE (absoluter Pfad für zu ändernde targetserver.conf, aus AWS)
# 4: KEEPALIVE (keepalive-Parameter, aus AWS, Beispiel "1")
# 5: SERVER (IP-Adresse des Upstreams mit Port, aus AWS, Beispiel "127.0.0.1:8080")
# 6: ZONE (zone-Parameter, aus AWS, Beispiel "80k")

usage(){
    echo "USAGE: $0 <service> <stage> <file> <keepalive> <server> <zone>"
    exit 1
}

appendUpstream(){
    echo "# MS $SERVICE ($STAGE)" >> $FILE
    echo "upstream $UPSTREAM_K8S {" >> $FILE
    echo "  zone $UPSTREAM_K8S $ZONE;" >> $FILE
    echo "  server $SERVER;" >> $FILE
    echo "  keepalive $KEEPALIVE;" >> $FILE
    echo "}" >> $FILE
}

removeUpstream(){
    START=$(grep -n "# MS $SERVICE ($STAGE)" $FILE | sed s/:.*//g)
    COUNT=$(wc -l < $FILE )
    #echo "upstream begins at $START of $COUNT lines"
    START_FROM_END=$((COUNT-START+1))
    #echo "start from end of file: $START_FROM_END"
    BLOCK_LENGTH=$(tail -n$START_FROM_END $FILE| grep -n -m1 "}" | sed s/:.*//g)
    #echo "Länge des Blocks: $BLOCK_LENGTH"
    HEAD_END=$((START-1))
    TAIL_START=$((START_FROM_END-BLOCK_LENGTH-1))  
    #echo "Zeilen vom Ende ohne Block: $TAIL_START"
    head -n$HEAD_END $FILE > temp.txt
    if [ $TAIL_START -gt 0 ]; then
        tail -n$TAIL_START $FILE >> temp.txt
    fi
    mv temp.txt $FILE
}

if [ $# -ne 6 ]; then
    echo "missing parameters!"
    usage
fi

SERVICE=$1
STAGE=$2
FILE=$3
KEEPALIVE=$4
SERVER=$5
ZONE=$6
UPSTREAM_K8S="mcbs.$SERVICE"_K8S

if [ ! -f $FILE ]; then
    echo "cannot read file '$FILE'!"
    exit 1
else
    echo "modifying file '$FILE'.."
fi

if [[ $(grep "# MS $SERVICE ($STAGE)" $FILE) != "" ]]; then
    echo "$FILE contains '# MS $SERVICE ($STAGE)', removing old upstream.."
    removeUpstream
    echo "$FILE adding new upstream $UPSTREAM_K8S"
    appendUpstream
    cat $FILE
else
    echo "no '$UPSTREAM_K8S' in $FILE, adding upstream.."
    appendUpstream
    cat $FILE
fi
