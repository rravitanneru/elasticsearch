#!/bin/bash

curl -X GET "172.29.240.6:9200/filebeat-*/_search" -H 'Content-Type: application/json' -d'
{
"query": {
  "bool": {
    "must": {
      "match_phrase": {
        "message": "Invalid user"
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
' >> it.json

jq .hits.hits it.json >> itresult.json

count=`cat itresult.json | wc -l`

if [ $count -ge 2 ]
then
echo "Triggring e-mail"
echo "PFA" | mutt -s "Intrusion Detected in Dev3"  ravikumar.tanneruu@omniwyse.com -a itresult.json
else
    echo "condition not met "
fi

rm -rfv it.json
rm -rfv itresult.json
