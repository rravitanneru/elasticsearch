#!/bin/bash

curl -X GET "172.29.240.6:9200/filebeat-*/_search" -H 'Content-Type: application/json' -d'
{
"query": {
  "bool": {
    "must": {
      "match_phrase": {
        "message": "auditd normal halt"
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
' >> ad.json

jq .hits.hits ad.json >> adresult.json

count=`cat adresult.json | wc -l`

if [ $count -ge 2 ]
then
echo "Triggring e-mail"
echo "PFA" | mutt -s "Audit daemon normal stop Detected in Dev3"  ravikumar.tanneruu@omniwyse.com -a adresult.json
else
    echo "condition not met "
fi

rm -rfv ad.json
rm -rfv adresult.json
