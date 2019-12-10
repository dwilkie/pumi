#!/bin/sh -l

set -e
set -o pipefail

for province_code in `seq 1 2`
do
  curl -s "http://db.ncdd.gov.kh/gazetteer/province/downloadprovince.castle?pv=$province_code" > "p$province_code.xls"
  ssconvert "p$province_code.xls" "p$province_code.csv"
done

cat "provinces.csv"
