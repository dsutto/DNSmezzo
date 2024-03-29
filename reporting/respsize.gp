# http://confuseddevelopment.blogspot.com/2009/01/creating-bar-charts-with-gnuplot.html
# http://gnuplot.sourceforge.net/demo/histograms.html

set terminal png
set style data histogram
set style histogram rowstacked
set style fill solid 0.5
set xtics rotate
set xlabel "Run date"
set ylabel "%age of responses"
set yrange [0:1.35] # Hack to get the key in a proper position
set title "Total packet size (in bytes) in .FR DNS responses"
plot "respsize.dat" using 2:xtic(1) title "0-127", "" using 3 title "128-255", "" using 4 title "256-511", "" using 5 title "512-1023", "" using 6 title "1023-2055","" using 7 title "2048-infinite"



