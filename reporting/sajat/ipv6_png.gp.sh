#!/bin/bash

gnuplot << EOF
set terminal png size 860,480
set output 'ipv6_png.png'

xmin = "`head -1 ipv6_png.dat | cut -d' ' -f 2,3`"
xmax = "`tail -1 ipv6_png.dat | cut -d' ' -f 2,3`"
set title "IPv6 fölött érkezett kérések száma"
set boxwidth 60 absolute
set style fill solid noborder
set xtics out rotate by -45 nomirror
set ytics out
set xdata time
set ylabel "Kérések száma másodpercenként"
set xlabel "UTC"
set format x "%H:%M"
set timefmt "%Y-%m-%d %H:%M:%S"
set yrange [0:]
set xrange [xmin:xmax]
set key off

set style line 1 linewidth 100
plot  "ipv6_png.dat" using 2:(\$4) with boxes
EOF

