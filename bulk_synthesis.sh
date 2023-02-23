#!/bin/bash

# Bash script that performs text-to-speech for multiple Lithuanian sentences
#

key=USER_SERVICE_KEY     # personal service key              
voice=laimis						 # selected voice [astra, lina, laimis, vytautas]
speed=1                  # 1 - normal, 0.75 - faster, 1.5 - slower
ext=m4a                  # extension of an audio filename [mp3, m4a]

function print_syntax {
  echo
  echo "Command syntax: ./bulk_synthesis list [filenames]"
  echo
  echo "  where list      is a list of sentences (UTF-8 encoded) to by synthesized"
  echo "        filenames is an optional list of filenames given for each sentence."
  echo "                  It must have the same number of lines as the 'list'."
  echo "                  If 'filenames' is missing, the sentence itself will be"
  echo "                  taken as a filename."
  echo 
  echo "  e.g. ./bulk_synthesis sentences.txt"
  echo  
  echo "  or   ./bulk_synthesis sentences.txt filenames.txt"
  echo
}

function process_sentence {
  # $1 - text
  # $2 - filename

  echo "$1" 
  data='{"text":"'$1'", "outputFormat": "'$ext'", "outputTextFormat": "none", "speed": '$speed', "voice":"'$voice'"}'

  curl -s -X POST https://sinteze.intelektika.lt/synthesis.service/prod/synthesize \
  -H 'Accept: application/json' \
  -H 'Content-Type: application/json' \
  -H 'Authorization: Key '"$key" \
  -d "$data" | jq -r '."audioAsString"' | base64 --decode -i > "$2"."$ext" 
}

if [ -z "$1" ]; then
    echo "You must supply the list of sentences as an argument."
    print_syntax
    exit -1
fi

if [ ! -f "$1" ]; then
    echo "File '$1' cannot be found."
    exit -1
fi

if [ ! -z "$2" ] && [ ! -f "$2" ]; then
    echo "File '$2' cannot be found."
    exit -1
fi

if [ -f "$2" ]; then
  # Use a separate list of filenames present in $2 
  while IFS= read -r p && IFS= read -r fname <&3; do
    process_sentence "$p" "$fname"
  done < "$1" 3< "$2"
else
  # Use the conmtent of a sentence as a filename
  while read p; do
    process_sentence "$p" "$p"
  done < "$1"
fi

exit 0
