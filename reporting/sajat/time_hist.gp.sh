#!/bin/bash

usage() {
  cat << EOF
usage: $0 [ -h [all] ] | -d data_file -o output [ -t title ] [ -x xlabel ] [ -y ylabel ] -f fields

  Generates a time based histogram of given datafile using gnuplot.

  OPTIONS:
    -h Show this message (with -v gives more help)
    -o Name of the output PNG file
    -d Source data file
    -f A whitespace separated list of the titles of data series (displayed as legend)
    -t Title of the diagram (default: empty)
    -x Label of horisontal axis (default: UTC)
    -y Label of vertical axis (default: empty)

EOF
}
verbose_help() {
  usage
  cat << EOF
  Data source file must have the format like
  2 2012-03-12 09:30:00 34 0 0 6 5 
  |     |         |     \____ ___/
  |     L date    |          v
  |               |        data
  L row id        L time

EOF
}

XLABEL=UTC

while getopts "h:o:d:f:t:x:y:" OPTION; do
    case $OPTION in 
	h)
	    if [ $OPTARG = "all" ]; then
		verbose_help
	    else
	        usage
	    fi
	    exit
	    ;;
	o)
	    OUTPUT=$OPTARG
	    ;;
	d)
	    DATAFILE=$OPTARG
	    ;;
	f)
	    DATASERIES=$OPTARG
	    ;;
	t)
	    TITLE=$OPTARG
	    ;;
	x)
	    XLABEL=$OPTARG
	    ;;
	y)
	    YLABEL=$OPTARG
	    ;;
	?)
	    usage
	    exit 1
	    ;;
    esac
done


if [ -z $DATAFILE ]; then
	echo "ERROR: Data source file must be given."
	usage
	exit 1
fi
if [ ! -s $DATAFILE ]; then
	echo "ERROR: Data source doesn't exist or is empty."
	exit 1
fi
if [ -z $OUTPUT ]; then
	echo "ERROR: Output file name must be given."
	usage
	exit 1
fi
if [ -z "$DATASERIES" ]; then
	echo "ERROR: Title list of data series must be given."
	usage
	exit 1
fi

((NF = `awk 'END {print NF}' $DATAFILE` - 3 ))
NUF=`echo $DATASERIES | wc -w`
if [ $NUF -ne $NF ]; then
	echo "ERROR: Data file contains $NF data columns, but $NUF titles were given."
	exit 1;
fi

for field in `seq $NF -1 1`; do
  dataspec="0"
  (( end = $field + 3 ))
  for num in `seq 4 $end`; do
    dataspec=${dataspec}+\$$num
  done
  [ ! -z "$plot_command" ] && plot_command=$plot_command", "
  plot_command=$plot_command"'$DATAFILE' using 2:($dataspec) with boxes linestyle $field title '`echo $DATASERIES | cut -d' ' -f $field`'"
done


gnuplot << EOF
set terminal png size 860,480
set output '$OUTPUT'

set style line 1 linecolor rgb "#6A99B8"
set style line 2 linecolor rgb "#A88971"
set style line 3 linecolor rgb "#1E4260"
set style line 4 linecolor rgb "#B0375C"
set style line 5 linecolor rgb "#1D1F1B"
set style line 6 linecolor rgb "#6A99B8"

set style line 10 linetype 0 linecolor rgb "#f3bfbf"
set style line 11 linetype 0 linecolor rgb "#dcdcdc"


xmin = "`head -1 $DATAFILE | cut -d' ' -f 2,3`"
xmax = "`tail -1 $DATAFILE | cut -d' ' -f 2,3`"
set title "$TITLE"
set key outside bottom center horizontal
set boxwidth 60 absolute
set style fill solid noborder
set xtics out rotate by -45 nomirror
set ytics out
set xdata time
set ylabel "$YLABEL"
set xlabel "$XLABEL"
set format x "%H:%M"
set timefmt "%Y-%m-%d %H:%M:%S"
set yrange [0:]
set xrange [xmin:xmax]
set grid mxtics back linestyle 11, linestyle 10
set grid mytics back linestyle 11, linestyle 10
set grid  xtics back linestyle 11, linestyle 10
set grid  ytics back linestyle 11, linestyle 10

plot $plot_command
EOF

