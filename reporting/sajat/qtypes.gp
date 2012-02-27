set terminal png size 860,480


xmin = "`head -1 qtypes.dat | cut -d' ' -f 2,3`"
xmax = "`tail -1 qtypes.dat | cut -d' ' -f 2,3`"
set title "QTYPE értékek az ns.nic.hu szerveren"
set key outside bottom center horizontal
set boxwidth 60 absolute
set style fill solid noborder
set xtics out rotate by -45 nomirror
set ytics out
set xdata time
set ylabel "Kérések száma másodpercenként"
set format x "%H:%M"
set timefmt "%Y-%m-%d %H:%M:%S"
set yrange [0:]
set xrange [xmin:xmax]

set style line 1 linecolor rgb "#39812A"
set style line 2 linecolor rgb "#71D935"
set style line 3 linecolor rgb "#E6FF52"
set style line 4 linecolor rgb "#0E3215"
set style line 5 linecolor rgb "#4AE0EB"

plot \
  'qtypes.dat' using 2:($5+$6+$4+$8+$7) with boxes linestyle 1 title "MX", \
  'qtypes.dat' using 2:($5+$6+$4+$8) with boxes linestyle 2 title "AAAA", \
  'qtypes.dat' using 2:($5+$6+$4) with boxes linestyle 3 title "A", \
  'qtypes.dat' using 2:($5+$6) with boxes linestyle 4 title "SOA", \
  'qtypes.dat' using 2:($5) with boxes linestyle 5 title "NS"
