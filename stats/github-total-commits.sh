#!/bin/bash

source stats.conf

# make tempfiles
GITLOGS=$(mktemp)
GITLOGS_PARSED=$(mktemp)
PLOT_DATA=$(mktemp)

if [ "$DEBUG" -eq "1" ] ; then
	echo "gitlog: ${GITLOGS}"
	echo "gitlog parsed: ${GITLOGS_PARSED}"
	echo "plot data: ${PLOT_DATA}"
fi

# getting data
cd ${GIT_GENTOO_PACKAGES} && git log --format='%ae,%ad' --date=short > ${GITLOGS}

# parsing
for line in $(cat /tmp/gitlogs.csv); do
	email=$(echo ${line} | cut -d "," -f 1)
	host=$(echo ${email} | cut -d "@" -f 2)
	date=$(echo ${line} | cut -d "," -f 2)
	yearmonth=${date:0:7}
	echo "${yearmonth},${host}" >> ${GITLOGS_PARSED}
done

# making plot data
for yearmonth in $(cat ${GITLOGS_PARSED} | cut -d "," -f 1 | sort -r | uniq); do
	if  [ "${yearmonth}" == "2016-12" ]; then
		continue
	fi

	if [ "${yearmonth}" == "2015-07" ]; then
		break
	fi

	total=$(cat ${GITLOGS_PARSED} | grep ${yearmonth} | wc -l)
	gentoo=$(cat ${GITLOGS_PARSED} | grep ${yearmonth} | grep "gentoo.org" | wc -l)
	other=$(($total - $gentoo))
	echo "${yearmonth},${total},${other}" >> ${PLOT_DATA}
done

# plot
gnuplot -e "plot_data='${PLOT_DATA}'" github-total-commits.plt

# cleanup
rm ${GITLOGS}
rm ${GITLOGS_PARSED}
rm ${PLOT_DATA}
