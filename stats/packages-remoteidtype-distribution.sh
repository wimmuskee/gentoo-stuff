#/bin/bash

source stats.conf

# making tempfiles
REMOTETYPES=$(mktemp)
REMOTETYPES_SORTCOUNT=$(mktemp)
PLOT_DATA=$(mktemp)

if [ "$DEBUG" -eq "1" ] ; then
	echo "remotetypes ${REMOTETYPES}"
	echo "remotetypes sorted counted ${REMOTETYPES_SORTCOUNT}"
	echo "plot data: ${PLOT_DATA}"
fi

# getting data
for category in $(cat ${GIT_GENTOO_PACKAGES}/profiles/categories); do
	for package_dir in $(find ${GIT_GENTOO_PACKAGES}/${category} -mindepth 1 -maxdepth 1 -type d); do
		PN=$(basename ${package_dir})
		remoteid=$(xsltproc --novalid --stringparam data remote-id metadata.xsl ${package_dir}/metadata.xml)
		
		type=$(echo ${remoteid} | cut -d ":" -f 1)
		if [[ ! -z ${type} ]]; then
			echo $type >> ${REMOTETYPES}
		else
			echo "unknown" >> ${REMOTETYPES}
		fi
	done
done

# making plot data
cat ${REMOTETYPES} | sort | uniq -c | sort -rn > ${REMOTETYPES_SORTCOUNT}

oldifs=$IFS
IFS=$'\n'
row=0
for line in $(cat /tmp/remotetypes-counted); do
	count=$(echo ${line} | grep -o [0-9]* | tr -d '\n')
	type=$(echo ${line} | grep -o [a-z].* | tr -d '\n')
	echo "${row} \"${type}\" ${count}" >> ${PLOT_DATA}
	let row=row+1
done
IFS=$oldifs

# plot and rotate
gnuplot -e "plot_data='${PLOT_DATA}'" packages-remoteidtype-distribution.plt
convert -rotate 90 packages-remoteidtype-distribution-90.png packages-remoteidtype-distribution.png

# cleanup
rm ${GITLOGS}
rm ${GITLOGS_PARSED}
rm ${PLOT_DATA}
