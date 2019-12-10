#!/bin/sh -l

set -e
set -o pipefail

mkdir -p tmp

for province_code in `seq 1 2`
do
  curl -s "http://db.ncdd.gov.kh/gazetteer/province/downloadprovince.castle?pv=$province_code" > "tmp/p$province_code.xls"
  ssconvert "tmp/p$province_code.xls" "tmp/p$province_code.csv"
done
