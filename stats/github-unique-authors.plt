if (!exists("plot_data")) plot_data='data.dat'
set title "Github packages: monthly unique author count"
set xdata time
set timefmt "%Y-%m"
set datafile separator ","
set terminal png size 480,400 enhanced truecolor font 'Verdana,9'
set output "github-unique-authors.png"
set ylabel "Authors"
set xlabel "Date"
set xrange ["2015-08":"2016-11"]
set pointsize 0.8
set format x "%Y-%m"
seconds_per_year=365*24*60*60
set xtics 0.5*seconds_per_year
set linetype 1 lc rgb "#beb8db" lw 1
set linetype 2 lc rgb "#54487a" lw 1
set border 11
set xtics out
set tics front
set key below
plot \
  plot_data using 1:($2) title 'total' with filledcurves x1, \
  plot_data using 1:($3) title 'non-gentoo.org' with filledcurves x1
