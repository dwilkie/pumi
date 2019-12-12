#!/bin/sh

set -e
set -o pipefail

echo $1
echo $2

for province_index in `seq 1 25`
do
  curl -s "http://db.ncdd.gov.kh/gazetteer/province/downloadprovince.castle?pv=$province_index" > "tmp/p$province_index.xls"
  ssconvert "tmp/p$province_index.xls" "tmp/p$province_index.csv"
done
