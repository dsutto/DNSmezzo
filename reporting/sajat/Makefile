STYLESHEET=page.xslt
DATE="` date +"%F %T"`"

all: index.html qtypes top100 nxdomain kaminsky ipv6

ipv6: 	 
	if [ ! -e ipv6-DATABASE ]; then touch ipv6-DATABASE; fi
	${MAKE} ipv6.html

ipv6.dat: ipv6-DATABASE general-plot.py 
	python general-plot.py ipv6_png > $@

#ipv6_perc.dat: ipv6-DATABASE general-plot.py
#	python general-plot.py ipv6_perc_png > $@

ipv6.png: ipv6.gp ipv6.dat
	if [ ! -s ipv6.dat ]; then echo "2 2011-01-01 00:00:00 0" > ipv6.dat; fi
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

greece2k: 
	if [ ! -e greece2k-DATABASE ]; then touch greece2k-DATABASE; fi
	${MAKE} greece2k.png

greece2k.dat: greece2k-DATABASE general-plot.py 
	python general-plot.py greece2k_png > $@

greece2k.png: greece2k.dat greece2k.gp 
	gnuplot greece2k.gp > $@

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

kaminsky: 
	if [ ! -e kaminsky-DATABASE ]; then touch kaminsky-DATABASE; fi
	${MAKE} kaminsky.html

kaminsky.dat: kaminsky-DATABASE general-plot.py 
	python general-plot.py kaminsky_png > $@

kaminsky.png: kaminsky.dat kaminsky.gp 
	gnuplot kaminsky.gp > $@

kaminsky.html: kaminsky-DATABASE kaminsky.tmpl.xhtml kaminsky.png
	python general-page.py kaminsky


# And here comes a hacking in order to overcome the lack of tal: modules in XHTML 1.0 DTD
%.tmpl.xhtml.tmp: %.tmpl.xml ${STYLESHEET}
	xsltproc  \
		--output $@ --stringparam lastmod $(DATE) ${STYLESHEET} $<

%.tmpl.xhtml: %.tmpl.xhtml.tmp
	sed 's/&lt;/</g' < $< | sed 's/&gt;/>/g' > $@

%.html: %.xml ${STYLESHEET} 
	xsltproc  \
		--output $@ --stringparam lastmod $(DATE) ${STYLESHEET} $< #&& xmllint  --valid $@

install: all
	cp -a -r -p *.html *.png img blueprint /home/sutda/results/
	
clean:
	rm -f *.png *.html *.dat *~ *DATABASE *.xhtml *.tmp

re: clean all
