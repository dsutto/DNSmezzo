STYLESHEET=page.xslt
LASTMOD="` date +"%F %T"`"
DATE="`date -d 'yesterday' +%Y/%m/%d`" #

all: index.html all_packets.html ipv6.html kaminsky.html networks_4.html non_IN_queries.html non_IN_stat.html nxdomain.html punycode.html qtypes.html top100.html top_resolvers.html queried_servers.html distrib_between_servers.html edns0_buffer_size.html rcodes.html

ipv6.html: ipv6_png.png ipv6.tmpl.xhtml

qtypes.html: qtypes_png.png qtypes.tmpl.xhtml

kaminsky.html: kaminsky_png.png kaminsky.tmpl.xhtml

rcodes.html: rcodes_png.png rcodes.tmpl.xhtml


# And here comes a hacking in order to overcome the lack of "tal:" modules in XHTML 1.0 DTD
%.tmpl.xhtml.tmp: %.tmpl.xml ${STYLESHEET}
	xsltproc --output $@ ${STYLESHEET} $<

%.tmpl.xhtml: %.tmpl.xhtml.tmp
	sed 's/&lt;/</g' < $< | sed 's/&gt;/>/g' | sed 's/&quot;/"/g'> $@
# End hacking

index.html: index.xml ${STYLESHEET} 
	xsltproc --output $@ --stringparam lastmod $(LASTMOD) ${STYLESHEET} $< #&& xmllint  --valid $@

%.html:  %.tmpl.xhtml
	python general-page.py --date=${DATE} $(*F)

%.png:
	python general-plot.py --date=${DATE} $(*F) 

%.lastchange:
	touch $@

install: all
	mkdir -p /home/sutda/results/$(DATE)
	cp -a -r -p *.html *.png img blueprint style /home/sutda/results/$(DATE)
	
clean:
	./cleanuptables
	rm -f *.png *.html *.dat *~ *DATABASE *.xhtml *.tmp

re: clean all
