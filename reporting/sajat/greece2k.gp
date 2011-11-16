set terminal png size 900,480

set tmargin 1
set border 3
set boxwidth 0.2
set key outside right




set style data histogram
set style histogram cluster gap 1  title  offset character 0, 0, 0
set style fill solid border -1
set boxwidth 0.9
set xtic rotate by -45


set xdata time
set timefmt "%Y-%m-%d %H:%M"
# Nem szep, hogy explicit szamokkal van megadva.
set xrange ["2011-10-21 18:51":"2011-10-28 14:28"]
set format x "%b. %d."
set timefmt "%Y-%m-%d %H:%M:%S"


set xrange [*:*]

set xlabel "Idő"
set ylabel "Kérések száma percenként"
set yrange [0:]
set key on
set title "QTYPE értékek greece2k.hu domain névre"
set style line 1 linewidth 100
plot \
  "greece2k.dat" using 2:4 title "A" with imp lw 1, \
  "greece2k.dat" using 2:8 title "AAAA" with imp lw 1, \
  "greece2k.dat" using 2:7 title "MX" with imp lw 1, \
  "greece2k.dat" using 2:5 title "NS" with imp lw 1, \
  "greece2k.dat" using 2:6 title "SOA" with imp lw 1
