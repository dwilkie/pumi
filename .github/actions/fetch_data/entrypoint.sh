#!/bin/sh

set -e
set -o pipefail

PLACEHOLDER='${province_code}'

num_provinces=$1
url=$2

for province_code in `seq 1 $num_provinces`
do
  province_url=$(echo $url | sed -e s/$PLACEHOLDER/$province_code/g)
  curl -s $province_url > "tmp/p$province_code.xls"
  ssconvert "tmp/p$province_code.xls" "tmp/p$province_code.csv"
done
