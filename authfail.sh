#!/bin/bash

curl -X GET "172.29.240.6:9200/filebeat-*/_search" -H 'Content-Type: application/json' -d'
{
"query": {
  "bool": {
    "must": {
      "match_phrase": {
        "message": "authentication failure"
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
' >> af.json

jq .hits.hits af.json >> afresult.json

count=`cat afresult.json | wc -l`

if [ $count -ge 2 ]
then
echo "Triggring e-mail"
echo "PFA" | mutt -s "Authentication Failure Detected in Dev3"  ravikumar.tanneruu@omniwyse.com -a afresult.json
else
    echo "condition not met "
fi

rm -rfv af.json
rm -rfv afresult.json
