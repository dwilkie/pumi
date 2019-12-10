#!/bin/sh -l

set -e
set -o pipefail

touch "csv_data/provinces.csv"
for province_code in `seq 1 2`
do
  curl -s "http://db.ncdd.gov.kh/gazetteer/province/downloadprovince.castle?pv=$province_code" > "p$province_code.xls"
  ssconvert "p$province_code.xls" "csv_data/p$province_code.csv"
  cat "csv_data/provinces.csv" "csv_data/p$province_code.csv" >> "csv_data/provinces.csv"
done

cat "csv_data/provinces.csv"
