set terminal png

set tmargin 1
set border 3
set boxwidth 0.2
set key right top




set style data histogram
set style histogram cluster gap 1  title  offset character 0, 0, 0
set style fill solid border -1
set boxwidth 0.9
set xtic rotate by -45


set xdata time
set timefmt "%Y-%m-%d %H:%M"
# Nem szep, hogy explicit szamokkal van megadva.
set xrange ["2011-10-21 18:51":"2011-10-28 14:28"]
set format x "%H:%M"
set timefmt "%Y-%m-%d %H:%M:%S"


set xrange [*:*]

set xlabel "Idő"
set ylabel "Kérések száma óránként"
set yrange [0:]
set key off
set title "IPv6 fölött érkezett kérések száma"
set style line 1 linewidth 100
plot \
  "ipv6.dat" using ($1):4:xtic(3) with imp lw 1
