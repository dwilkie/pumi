#!/bin/sh -l

mkdir -p csv
curl -s "http://db.ncdd.gov.kh/gazetteer/province/downloadprovince.castle?pv=1" > p1.xls
ssconvert p1.xls csv/p1.csv
cat csv/p1.csv
