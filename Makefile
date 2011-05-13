# http://stackoverflow.com/questions/154630/recommended-gcc-warning-options-for-c
# http://gcc.gnu.org/onlinedocs/gcc-4.3.2/gcc/Warning-Options.html
CFLAGS=-Wall -Wextra -g -O0
LDFLAGS=-lpcap -lpq 
# On NetBSD, compile with:
# gmake CFLAGS="-Wall -Wextra -g -O0 -I/usr/pkg/include" LDFLAGS="-L/usr/pkg/lib -lpcap -lpq"
# On FreeBSD, compile with:
# gmake CFLAGS="-Wall -Wextra -g -O0 -I/usr/local/include" LDFLAGS="-L/usr/local/lib -lpcap -lpq"
# On UltraSparc and probably on Alpha, add -DPICKY_WITH_ALIGNMENT

BASE_NAME=DNSmezzo
TARBALL=/tmp/${BASE_NAME}.tar
GZIP=gzip --best --force --verbose
RM=rm -f
MV=mv -f

all: packets2postgresql test1

%.o: %.c packet-defs.h packet-headers.h
	${CC} ${CFLAGS} -c $<

test1: test1.o pcap-parse.o
	${CC} ${LDFLAGS} -o $@ $^

packets2postgresql: packets2postgresql.o pcap-parse.o
	${CC} ${LDFLAGS} -o $@ $^

dnstypes: dns-parameters.sql

dns-parameters.sql: dns-parameters
	./dnsparameters2sql.py > $@ || rm -f $@

dns-parameters:
	wget -O $@ http://www.iana.org/assignments/dns-parameters

dist: clean
	(cd domain-name-type; ${MAKE} clean)
	(cd ..; tar --create --exclude=.svn --exclude=*.pcap --exclude=*~ --exclude=store-dbms --exclude=Kiminsky --exclude=nxdomain --exclude=*.out --exclude=*.log --verbose --file ${TARBALL} ${BASE_NAME})	
	${GZIP} ${TARBALL}

clean:
	${RM} *.o test1 packets2postgresql *~

