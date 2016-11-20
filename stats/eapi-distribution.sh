#/bin/bash
# get all eapi versions and overlaynumber for each ebuild listed by eix
# filter only lines without an overlaynumber, the default tree
# sort, count, and make a csv
# reorder counts and labels for gnuplot datastructure
# plot

EIX_LIMIT=0

NAMEVERSION="<eapi>-<overlaynum>\n" eix --format '<availableversions:NAMEVERSION>' --pure-packages > /tmp/eapis-total.txt

rm -f /tmp/eapis.txt
touch /tmp/eapis.txt

for line in $(cat /tmp/eapis-total.txt); do
	eapi=$(echo $line | cut -d "-" -f 1)
	overlay=$(echo $line | cut -d "-" -f 2)

	if [ -z ${overlay} ]; then
		echo ${eapi} >> /tmp/eapis.txt
	fi
done

cat /tmp/eapis.txt | sort | uniq -c | grep -o  "[0-9]*\ [0-9]*$" | tr " " "," > /tmp/eapis-distribution.txt

rm -f data.dat
touch data.dat

row=0
for line in $(cat /tmp/eapis-distribution.txt); do
	count=$(echo $line | cut -d "," -f 1)
	eapi=$(echo $line | cut -d "," -f 2)

	echo "${row} \"${eapi}\" ${count}" >> data.dat
	let row=row+1
done

gnuplot eapi-distribution.plt
