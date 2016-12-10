# create it with an angle, to concert it later, gnuplot can't draw horizontally
if (!exists("plot_data")) plot_data='data.dat'
set terminal png
set output "packages-remoteidtype-distribution-90.png"
unset key
set linetype 1 lc rgb "#54487a" lw 1
set boxwidth 0.7
set style fill solid
# draw title, and leave margin for it
set label 11 center at graph 0.5,char 1 "metadata.xml remote-id type distribution" rotate by 90 offset -27,12
set lmargin 6
set xtics rotate by 90 scale 0
set xtics right offset 0,0
set label 1 'type' at graph 0.5, -0.45 centre rotate by 180
unset ytics
set y2tics rotate by 125
set y2tics left offset 2,-1.9
set y2label 'packages' offset -0.5
set yrange [0:12000]
set y2tics 2000,2000,12000
plot plot_data using 1:3:xtic(2) with boxes
