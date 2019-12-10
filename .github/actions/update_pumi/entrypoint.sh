#!/bin/sh -l

for province_code in `seq 1 2`
do
   curl -s "http://db.ncdd.gov.kh/gazetteer/province/downloadprovince.castle?pv=$province_code" > "p$province_code.xls"
   ssconvert "p$province_code.xls" "csv_data/p$province_code.csv"
done
