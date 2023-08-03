#!/bin/bash
set -e

cd "$(dirname "$0")"

EVENT_DIR=events
OUTPUT_DIR=output

rm -rf -- $OUTPUT_DIR

WARNINGS=""

echo "Compiling events in $EVENT_DIR"
echo "Outputting to $OUTPUT_DIR"
FILES=$(find ${EVENT_DIR} -type f -name "*.avdl")
for f in $FILES
do
    echo "Processing $f ..."
    CMD="avro-tools idl2schemata $f $OUTPUT_DIR/generated"
    RESULT=`eval $CMD`

    [[ "$f" =~ /([-_0-9a-zA-Z]+)\.avdl ]]
    AVSC=${BASH_REMATCH[1]}
    mv $OUTPUT_DIR/generated/$AVSC.avsc $OUTPUT_DIR/$AVSC.avsc
    echo "Created $OUTPUT_DIR/$AVSC.avsc, extracted from the generated files"

    if [[ $RESULT =~ \[WARNING\]  || $RESULT =~ "Exception in thread" ]]; then
        WARNINGS="$WARNINGS$f: $RESULT"'\n'
    fi
done
#Optional: You can choose not to delete the generated files. 
#They're not necessary for registering to the Schema registry
# rm -rf $OUTPUT_DIR/generated

if [[ $WARNINGS != "" ]]; then
    echo -e "\nSome schemas had warnings during compilation: \n"
    echo -e $WARNINGS
    echo "Done"
    exit 1
fi

echo "Done"



