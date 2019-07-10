#!/bin/bash

cmd=$1
echo $1
echo "running $cmd && date"
echo "$cmd && date"| bash

function testzip(){
zip --test $1 1>/dev/null && echo $1 'OK'
if (($? > 0)); then
   # use double quote for $f to function
   retval="-1"
else
   retval="0"
fi
echo $retval
}

filename=$(echo "$cmd" | grep -o -P '([^\/]+$)')
echo "$filename"

retval=$(testzip ${filename})

while [ "$retval" = "-1" ]
do
  echo "zip test failed, removing zip file and retrying download"
  echo "$filename"
  rm -rf  ${filename}
  echo "$cmd && date"| bash
  retval=$(testzip ${filename})
done

echo "zip file is good"

