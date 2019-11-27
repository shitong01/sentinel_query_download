#!/bin/bash

cmd=$1
echo $1
echo "running $cmd && date"
time echo "$cmd && date"| bash

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

function testzip2(){
file=$1
simple_file="${file%.*}"

#getting uuid from scihub
#md5val=$(curl "https://api.daac.asf.alaska.edu/services/search/param?platform=SA,SB&processingLevel=METADATA_SLC&granule_list=${simple_file}&output=json" | python -c "import sys, json; print(json.load(sys.stdin)[0][0]['md5sum'])")
#md5val= $( curl -n "https://scihub.copernicus.eu/dhus/odata/v1/Products('71368989-3b8b-447a-9cee-23410f254b3b')" | xmllint -format - |  sed -n 's:.*<d\:Value>\(.*\)</d\:Value>.*:\1:p')
md5val=$(curl -G -gn "https://scihub.copernicus.eu/dhus/odata/v1/Products" --data-urlencode "\$filter=Name eq '${simple_file}'" | xmllint -format - |  sed -n 's:.*<d\:Value>\(.*\)</d\:Value>.*:\1:p')
md5val_file=$(md5sum $file | awk '{ print $1 }')
echo "md5sum from query: ${md5val,,}"
echo "md5sum from file : ${md5val_file,,}"
if [[ "${md5val,,}" == "${md5val_file,,}" ]]; then
    retval=0
    echo $file 'OK'
else
    retval=1
fi
}

filename=$(echo "$cmd" | grep -o -P '([^\/]+$)')
echo "testing zip for: $filename"

testzip2 ${filename}
echo This is return value: $retval
counter=1

while [ $retval = 1 ]
do
  echo "The counter is $counter"
  if [ $counter -gt 2 ];
      then
      echo "We have exceeded 2 retries. Stopping the loop. "
      break
  fi
  echo "zip test failed, removing zip file and retrying download"
  echo "$filename"
  rm -rf  ${filename}
  time echo "$cmd && date"| bash
  testzip2 ${filename}
  echo This is return value: $retval
  counter=$(( $counter + 1 ))
done

if  [ $retval = 0 ]; then
echo "zip file is good"
fi
