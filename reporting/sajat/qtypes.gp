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
# Nem szep, hogy explicit szamokkal van megadva.
# set timefmt "%Y-%m-%d %H:%M"
# set xrange ["2011-10-21 18:51":"2011-10-28 14:28"]
set format x "%H:%M"
set timefmt "%Y-%m-%d %H:%M:%S"
set yrange [0:]
set xrange [xmin:xmax]

plot \
  'qtypes.dat' using 2:($5+$6+$8+$4+$7) with boxes title "MX", \
  'qtypes.dat' using 2:($5+$6+$8+$4) with boxes title "A", \
  'qtypes.dat' using 2:($5+$6+$8) with boxes title "AAAA", \
  'qtypes.dat' using 2:($5+$6) with boxes title "SOA", \
  'qtypes.dat' using 2:($5) with boxes title "NS"
