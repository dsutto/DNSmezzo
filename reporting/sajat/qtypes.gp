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
set key on
set title "QTYPE értékek az ns.nic.hu szerveren"
set style line 1 linewidth 100
plot \
  "qtypes.dat" using ($1):4:xtic(3) title "A" with imp lw 1, \
  "qtypes.dat" using ($1+0.1):5 title "AAAA" with imp lw 1, \
  "qtypes.dat" using ($1+0.2):9 title "DNSKEY" with imp lw 1, \
  "qtypes.dat" using ($1+0.3):10 title "MX" with imp lw 1, \
  "qtypes.dat" using ($1+0.4):12 title "NS" with imp lw 1
