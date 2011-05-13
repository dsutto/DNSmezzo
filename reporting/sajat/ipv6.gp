set terminal png

set tmargin 1
set border 3
set boxwidth 0.2
set key right top
set tics scale 0




set style data histogram
set style histogram cluster gap 1  title  offset character 0, 0, 0
set style fill solid border -1
set boxwidth 0.9
set xtic rotate by -45




set xrange [*:*]

set xlabel "Idő"
set ylabel "Kérések száma"
set yrange [0:]
set key off
set title "IPv6 fölött érkezett kérések száma"
set style line 1 linewidth 100
plot \
  "ipv6.dat" using ($1):4:xtic(3) with imp lw 10
