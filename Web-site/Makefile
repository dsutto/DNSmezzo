ALLHTML=$(shell ls *.xml 2> /dev/null | sed 's/.xml$$/.html/' )
STYLESHEET=page.xslt
IMAGES=$(shell ls *.pdf)
CSS=
TARBALL=/tmp/DNSmezzo.tar.gz
ME=$(shell hostname)
ifeq ("${ME}","lilith")
WEBSERVER=/var/www/www.dnsmezzo.net
else
WEBSERVER=bortzmeyer@lilith.generic-nic.net:/var/www/www.dnsmezzo.net
endif
GOOGLEVERIF=google75f3cadf7e9fc996.html

all: ${ALLHTML} ${TARBALL}.gz

%.html: %.xml ${STYLESHEET} 
	xsltproc  \
		 --output $@ ${STYLESHEET} $< && xmllint --noout --valid $@

install: all 
	#touch ${GOOGLEVERIF}
	rsync -q -a ${ALLHTML} ${GOOGLEVERIF} ${IMAGES} ${CSS} ${TARBALL} ${WEBSERVER}

${TARBALL}.gz: 
	(cd ..; make dist)

clean:
	rm -f *.html *~ 


