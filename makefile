SRCS:=api.c
PDFS:=${SRCS} ${SRCS:.c=.h} makefile main.c xbee.h globals.h

CC:=gcc
CFLAGS:=-Wall -Wstrict-prototypes -pedantic -c -fPIC ${DEBUG}
CLINKS:=-lm ./lib/libxbee.so -lpthread ${DEBUG}
#DEBUG:=-g -DDEBUG
DEFINES:=

ENSCRIPT:=-MA4 --color -f Courier8 -C --margins=15:15:0:20
ifneq ($(strip $(wildcard /usr/share/enscript/mine-web.hdr)),)
  ENSCRIPT+= --fancy-header=mine-web
else
  ENSCRIPT+= --fancy-header=a2ps
endif


SRCS:=${sort ${SRCS}}
PDFS:=${sort ${PDFS}}

.PHONY: all run new clean cleanpdfs main pdfs install install_su uninstall uninstall_su


# all - do everything (default) #
all: main
	@echo "*** Done! ***"


# run - remake main and then run #
run: ./lib/libxbee.so.1.0.1 main
	LD_LIBRARY_PATH=./lib:$LD_LIBRARY_PATH ./bin/main


# new - clean and do everything again #
new: clean all


# clean - remove any compiled files and PDFs #
clean:
	rm -f ./*~
	rm -f ./obj/*.o
	rm -f ./lib/libxbee.so*
	rm -f ./bin/main

cleanpdfs:
	rm -f ./pdf/*.pdf


# install - installs library #
install: /usr/lib/libxbee.so.1.0.1

/usr/lib/libxbee.so.1.0.1: ./lib/libxbee.so.1.0.1
	@echo
	@echo
	@echo "################################################################"
	@echo "### To Install this library I need the root password please! ###"
	@echo "################################################################"
	su -c "make install_su --no-print-directory"
	@echo
	@echo

install_su:
	cp ./lib/libxbee.so.1.0.1 /usr/lib/libxbee.so.1.0.1 -f
	chmod 755 /usr/lib/libxbee.so.1.0.1
	chown root:root /usr/lib/libxbee.so.1.0.1

	cp /usr/lib/libxbee.so.1.0.1 /usr/lib/libxbee.so.1 -sf
	chown root:root /usr/lib/libxbee.so.1

	cp /usr/lib/libxbee.so.1.0.1 /usr/lib/libxbee.so -sf
	chown root:root /usr/lib/libxbee.so

	cp ./xbee.h /usr/include/xbee.h -f
	chmod 644 /usr/include/xbee.h
	chown root:root /usr/include/xbee.h

uninstall:
	@echo
	@echo
	@echo "##################################################################"
	@echo "### To Uninstall this library I need the root password please! ###"
	@echo "##################################################################"
	su -c "make uninstall_su --no-print-directory"
	@echo
	@echo

uninstall_su:
	rm /usr/lib/libxbee.so.1.0.1 -f
	rm /usr/lib/libxbee.so.1 -f
	rm /usr/lib/libxbee.so -f
	rm /usr/include/xbee.h -f

# main - compile & link objects #
main: ./bin/main

./bin/main: ./lib/libxbee.so.1.0.1 ./bin/ ./obj/main.o
	${CC} ${CLINKS} ./main.c -o ./bin/main ${DEBUG}

./bin/:
	mkdir ./bin/

./lib/libxbee.so.1.0.1: ./lib/ ./obj/ ${addprefix ./obj/,${SRCS:.c=.o}} ./xbee.h
	gcc -shared -Wl,-soname,libxbee.so.1 -o ./lib/libxbee.so.1.0.1 ./obj/*.o -lrt
	ln ./libxbee.so.1.0.1 ./lib/libxbee.so.1 -s
	ln ./libxbee.so.1.0.1 ./lib/libxbee.so -s

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
