#!/bin/sh -l

for i in {1..5}
do
   echo "http://db.ncdd.gov.kh/gazetteer/province/downloadprovince.castle?pv=$i"
   curl -s "http://db.ncdd.gov.kh/gazetteer/province/downloadprovince.castle?pv=$i" > "pv$i.xls"
   ssconvert "pv$i.xls" "csv/pv$i.csv"
   cat "csv/pv$i.csv"
done
