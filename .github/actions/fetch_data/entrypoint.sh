#!/bin/sh

set -e
set -o pipefail

if [ "$1" = 'fetch-data' ]; then
  URL="https://db.ncdd.gov.kh/gazetteer/province/downloadprovince.castle?pv=PROVINCE_CODE"
  PLACEHOLDER="PROVINCE_CODE"
  NUM_PROVINCES="25"

  for province_code in `seq 1 $NUM_PROVINCES`
  do
    province_url=$(echo $URL | sed -e s/$PLACEHOLDER/$province_code/g)
    curl -k -s $province_url > "tmp/p$province_code.xls"
    ssconvert "tmp/p$province_code.xls" "tmp/p$province_code.csv"
  done
else
  exec "$@"
fi
