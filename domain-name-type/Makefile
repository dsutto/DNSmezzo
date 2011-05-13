# TODO: may be we could use the PostgreSQL build system, PGXS?

INCLUDES_PGSQL=$(shell pg_config --includedir-server) 
LIBRARIES=domain-name.o
CC_SHARED_OPTIONS=-fpic -shared 
CC_STATIC_OPTIONS=-static
DATABASE=test
DEBUG=-g -O0
MALLOC=palloc
FREE=pfree
CFLAGS=-Wall -Wextra ${DEBUG} 
MALLOCFLAGS=-DMALLOC=${MALLOC} 
CC=gcc
TARBALL=/tmp/domain-name-type.tar
SU=sudo -u postgres

all: domain-name.o domain-name.so

%.o: %.c domain-name.h
	${CC} ${CFLAGS} -c -o $@ $<

test: test-domain-name
	./test-domain-name Ns1.eXEMple.Fr ns1.exemple.fr 
	./test-domain-name www.exemple.com.fr www.exemple.com.fr
	./test-domain-name www.example.co.uk www.exemple.fr
	# The next ones are invalid
	#./test-domain-name "" "..."
	./test-domain-name example.net exemple.fr

test-domain-name: test-domain-name.o domain-name.h ${LIBRARIES}
	${CC} ${CFLAGS}  -o $@ $< ${LIBRARIES}

test-db: install
	psql -f test-domain-name.sql ${DATABASE}

domain-name.so: domain-name-glue.c ${LIBRARIES}
	${CC} ${CFLAGS} ${MALLOCFLAGS} -I${INCLUDES_PGSQL} \
		${CC_SHARED_OPTIONS} ${LIBRARIES} -o $@ $<

install: all
	${SU} psql -f domain-name.sql ${DATABASE}

clean:
	rm -f *.o 

realclean: clean 
	rm -f *~

