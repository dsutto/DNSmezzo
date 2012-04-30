#!/bin/bash

gnuplot << EOF
set terminal png
set output 'kaminsky_png.png'

set tmargin 3
set border 3
set boxwidth 0.2
set key right top




set style fill solid border -1
set boxwidth 0.9
set xtic rotate by -45

set ytics 10
set x2tics ("<poor | good>" 0.62, "<good | great>" 0.86)
set grid noxtics x2tics




set xrange [*:*]

set xlabel "Azonos forrás porttal érkező kérések aránya"
set ylabel "Rezolverek száma"
set format y "%g %%"
set yrange [0:]
set key off
set title "SPR - Source Port Randomization"
set style line 1 linewidth 100
plot \
  "< awk -v tot=`awk '{tot+=$2} END {print tot}' kaminsky_png.dat` -f kaminsky.awk kaminsky_png.dat" using (\$3):(\$2*100) with lines lw 2
EOF
