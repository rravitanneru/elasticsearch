#!/bin/bash

curl -X GET "172.29.240.6:9200/filebeat-*/_search" -H 'Content-Type: application/json' -d'
{
"query": {
  "bool": {
    "must": {
      "match_phrase": {
        "message": "auditd daemon stopped brutally"
      }
    },
    "filter": {
      "range": {
        "@timestamp": {
          "from": "now-2m",
          "to": "now"
        }
      }
    }
  }
}
}
' >> adb.json

jq .hits.hits adb.json >> adbresult.json

count=`cat adbresult.json | wc -l`

if [ $count -ge 2 ]
then
echo "Triggring e-mail"
echo "PFA" | mutt -s "Auditd daemon stopped brutally in Dev3"  ravikumar.tanneruu@omniwyse.com -a adbresult.json
else
    echo "condition not met "
fi

rm -rfv adb.json
rm -rfv adbresult.json
