SRCS:=api.c
MANS:=man3/libxbee.3 man3/xbee_setup.3 man3/xbee_newcon.3 man3/xbee_getpacket.3 man3/xbee_senddata.3 man3/xbee_vsenddata.3
PDFS:=${SRCS} ${SRCS:.c=.h} makefile main.c xbee.h globals.h

CC:=gcc
CFLAGS:=-Wall -Wstrict-prototypes -pedantic -c -fPIC ${DEBUG}
CLINKS:=-lm ./lib/libxbee.so.1.0.1 -lpthread ${DEBUG}
#DEBUG:=-g -DDEBUG
DEFINES:=

MANPATH:=${shell manpath|cut -d : -f 1}

ENSCRIPT:=-MA4 --color -f Courier8 -C --margins=15:15:0:20
ifneq ($(strip $(wildcard /usr/share/enscript/mine-web.hdr)),)
  ENSCRIPT+= --fancy-header=mine-web
else
  ENSCRIPT+= --fancy-header=a2ps
endif


SRCS:=${sort ${SRCS}}
PDFS:=${sort ${PDFS}}

.PHONY: all run new clean cleanpdfs main pdfs install install_su uninstall uninstall_su uninstall_man/

FORCE:

# all - do everything (default) #
all: main
	@echo "*** Done! ***"


# run - remake main and then run #
run: main
	LD_LIBRARY_PATH=./lib:$LD_LIBRARY_PATH ./bin/main


# new - clean and do everything again #
new: clean all


# clean - remove any compiled files and PDFs #
clean:
	rm -f ./*~
	rm -f ./sample/*~
	rm -f ./obj/*.o
	rm -f ./lib/libxbee.so*
	rm -f ./bin/main

cleanpdfs:
	rm -f ./pdf/*.pdf


# install - installs library #
install:
	@echo
	@echo
	@echo "################################################################"
	@echo "### To Install this library I need the root password please! ###"
	@echo "################################################################"
	su -c "make install_su --no-print-directory"
	@echo
	@echo

install_su: /usr/lib/libxbee.so.1.0.1 /usr/include/xbee.h ${addsuffix .bz2,${addprefix ${MANPATH}/,${MANS}}}

/usr/lib/libxbee.so.1.0.1: ./lib/libxbee.so.1.0.1
	cp ./lib/libxbee.so.1.0.1 /usr/lib/libxbee.so.1.0.1 -f
	@chmod 755 /usr/lib/libxbee.so.1.0.1
	@chown root:root /usr/lib/libxbee.so.1.0.1
	cp /usr/lib/libxbee.so.1.0.1 /usr/lib/libxbee.so.1 -sf
	@chown root:root /usr/lib/libxbee.so.1
	cp /usr/lib/libxbee.so.1.0.1 /usr/lib/libxbee.so -sf
	@chown root:root /usr/lib/libxbee.so

/usr/include/xbee.h: ./xbee.h
	cp ./xbee.h /usr/include/xbee.h -f
	@chmod 644 /usr/include/xbee.h
	@chown root:root /usr/include/xbee.h

${MANPATH}/%.bz2: ./man/%
	cat $< | bzip2 -z > $@
	@chmod 644 $@
	@chown root:root $@

uninstall:
	@echo
	@echo
	@echo "##################################################################"
	@echo "### To Uninstall this library I need the root password please! ###"
	@echo "##################################################################"
	su -c "make uninstall_su --no-print-directory"
	@echo
	@echo

uninstall_su: ${addprefix uninstall_man/,${MANS}}
	rm /usr/lib/libxbee.so.1.0.1 -f
	rm /usr/lib/libxbee.so.1 -f
	rm /usr/lib/libxbee.so -f	
	rm /usr/include/xbee.h -f

uninstall_man/%:
	rm ${MANPATH}/$*.bz2 -f

# main - compile & link objects #
main: ./bin/main

./bin/main: ./lib/libxbee.so.1.0.1 ./bin/ ./main.c
	${CC} ${CLINKS} ./main.c -o ./bin/main ${DEBUG}

./bin/:
	mkdir ./bin/

./lib/libxbee.so.1.0.1: ./lib/ ./obj/ ${addprefix ./obj/,${SRCS:.c=.o}} ./xbee.h
	gcc -shared -Wl,-soname,libxbee.so.1 -o ./lib/libxbee.so.1.0.1 ./obj/*.o -lrt
ifeq ($(strip $(wildcard ./lib/libxbee.so.1)),)
	ln ./libxbee.so.1.0.1 ./lib/libxbee.so.1 -sf
endif
ifeq ($(strip $(wildcard ./lib/libxbee.so)),)
	ln ./libxbee.so.1.0.1 ./lib/libxbee.so -sf
endif

./lib/:
	mkdir ./lib/

./obj/:
	mkdir ./obj/

./obj/%.o: %.c %.h xbee.h globals.h
	${CC} ${CFLAGS} ${DEFINES} ${DEBUG} $*.c -o $@

./obj/%.o: %.c xbee.h globals.h
	${CC} ${CFLAGS} ${DEFINES} ${DEBUG} $*.c -o $@


# pdfs - generate PDFs for each source file #
ifneq ($(strip $(wildcard /usr/bin/enscript)),)
ifneq ($(strip $(wildcard /usr/bin/ps2pdf)),)
pdfs: ./pdf/ ${addprefix ./pdf/,${addsuffix .pdf,${PDFS}}}

./pdf/:
	mkdir ./pdf/

./pdf/makefile.pdf: ./makefile
	enscript ${ENSCRIPT} -Emakefile $< -p - | ps2pdf - $@

./pdf/%.pdf: %
	enscript ${ENSCRIPT} -Ec $< -p - | ps2pdf - $@

./pdf/%.pdf:
	@echo "*** Cannot make $@ - '$*' does not exist ***"
else
pdfs:
	@echo "WARNING: ps2pdf is not installed - cannot generate PDF files"
endif
else
pdfs:
	@echo "WARNING: enscript is not installed - cannot generate PDF files"
endif
