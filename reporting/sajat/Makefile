STYLESHEET=page.xslt

all: index.html qtypes top100 nxdomain ipv6

ipv6: 	
	if [ ! -e ipv6-DATABASE ]; then touch ipv6-DATABASE; fi
	${MAKE} ipv6.html

ipv6.dat: ipv6-DATABASE general-plot.py
	python general-plot.py ipv6_png > $@

#ipv6_perc.dat: ipv6-DATABASE general-plot.py
#	python general-plot.py ipv6_perc_png > $@

ipv6.png: ipv6.dat ipv6.gp
	gnuplot ipv6.gp > $@

# ipv6_perc.png: ipv6_perc.dat ipv6_perc.gp
#	gnuplot ipv6_perc.gp > $@

ipv6.html: ipv6-DATABASE general-page.py ipv6.png ipv6.tmpl.xhtml
	python general-page.py ipv6

qtypes:
	if [ ! -e qtypes-DATABASE ]; then touch qtypes-DATABASE; fi
	${MAKE} qtypes.html

qtypes.dat: qtypes-DATABASE general-plot.py
	python general-plot.py qtypes_png > $@

qtypes.png: qtypes.dat qtypes.gp
	gnuplot qtypes.gp > $@

qtypes.html: qtypes-DATABASE qtypes.png qtypes.tmpl.xhtml
	python general-page.py qtypes

nxdomain: 	
	if [ ! -e nxdomain-DATABASE ]; then touch nxdomain-DATABASE; fi
	${MAKE} nxdomain.html

nxdomain.html: nxdomain-DATABASE nxdomain.tmpl.xhtml
	python general-page.py nxdomain

top100:
	if [ ! -e top100-DATABASE ]; then touch top100-DATABASE; fi
	${MAKE} top100.html

top100.html: top100-DATABASE top100.tmpl.xhtml
	python general-page.py top100
# 
# updates:
# 	if [ ! -e updates-DATABASE ]; then touch updates-DATABASE; fi
# 	${MAKE} updates.html
# 
# updates.dat: updates-DATABASE plot-updates.py
# 	python plot-updates.py > $@
# 
# updates.png: updates.dat updates.gp
# 	gnuplot updates.gp > $@
# 
# updates.html: updates-DATABASE updates-page.py updates.png updates.tmpl.xhtml
# 	python updates-page.py
# 
# respsize:
# 	if [ ! -e respsize-DATABASE ]; then touch respsize-DATABASE; fi
# 	${MAKE} respsize.html
# 
# respsize.dat: respsize-DATABASE plot-respsize.py
# 	python plot-respsize.py > $@
# 
# respsize.png: respsize.dat respsize.gp
# 	gnuplot respsize.gp > $@
# 
# respsize.html: respsize-DATABASE respsize-page.py respsize.png respsize.tmpl.xhtml
# 	python respsize-page.py

%.tmpl.html
%.html: %.xml ${STYLESHEET} 
	xsltproc  \
		--output $@ ${STYLESHEET} $< #&& xmllint  --valid $@

install: all
	cp -a -p *.html *.png /var/www/results.dnsmezzo.net/
	
clean:
	rm -f *.png *.html *.dat *~ *DATABASE

re: clean all
