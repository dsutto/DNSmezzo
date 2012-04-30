#!/bin/bash
gnuplot << EOF
set terminal png size 860,480
set output 'qtypes_png.png'

set style line 1 linecolor rgb "#39812A"
set style line 2 linecolor rgb "#71D935"
set style line 3 linecolor rgb "#E6FF52"
set style line 4 linecolor rgb "#0E3215"
set style line 5 linecolor rgb "#4AE0EB"

set style line 10 linetype 0 linecolor rgb "#f3bfbf"
set style line 11 linetype 0 linecolor rgb "#dcdcdc"


xmin = "`head -1 qtypes_png.dat | cut -d' ' -f 2,3`"
xmax = "`tail -1 qtypes_png.dat | cut -d' ' -f 2,3`"
set title "QTYPE értékek az ns.nic.hu és az ns1.nic.hu szerveren"
set key outside bottom center horizontal
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
set grid mxtics back linestyle 11, linestyle 10
set grid mytics back linestyle 11, linestyle 10
set grid  xtics back linestyle 11, linestyle 10
set grid  ytics back linestyle 11, linestyle 10

plot \
  'qtypes_png.dat' using 2:(\$5+\$6+\$4+\$8+\$7) with boxes linestyle 1 title "MX", \
  'qtypes_png.dat' using 2:(\$5+\$6+\$4+\$8) with boxes linestyle 2 title "AAAA", \
  'qtypes_png.dat' using 2:(\$5+\$6+\$4) with boxes linestyle 3 title "A", \
  'qtypes_png.dat' using 2:(\$5+\$6) with boxes linestyle 4 title "SOA", \
  'qtypes_png.dat' using 2:(\$5) with boxes linestyle 5 title "NS"
EOF
