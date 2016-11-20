set terminal png
set output "eapi-distribution.png"

set title "EAPI distribution across ebuilds (2016-11-20)"
set xlabel "EAPI"
set ylabel "ebuilds"
unset key
set linetype 1 lc rgb "#54487a" lw 1
set boxwidth 0.5
set style fill solid
plot "data.dat" using 1:3:xtic(2) with boxes

