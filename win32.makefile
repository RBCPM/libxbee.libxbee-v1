#-- uncomment this to enable debugging
#DEBUG:=/Zi

#-- you may need to edit these lines if your installation is different
VCPath:=C:\Program Files (x86)\Microsoft Visual Studio 9.0\VC
SDKPath:=C:\Program Files\Microsoft SDKs\Windows\v6.0A


###### YOU SHOULD NOT CHANGE BELOW THIS LINE ######

SRCS:=api.c

CC:="${VCPath}\bin\cl.exe"

all: .\obj .\lib
	${CC} \
		${DEBUG} \
		/nologo \
		/MT \
		/Ox \
		/Gz \
		"/I${VCPath}\Include" \
		"/I${SDKPath}\Include" \
		/Fo.\obj\libxbee.obj \
		/Fe.\lib\libxbee.dll \
		${SRCS} \
		/LD \
		/link \
		/MAP:lib\libxbee.map \
		/IDLOUT:win32.idl \
		/DEF:win32.def \
		"/LIBPATH:${VCPath}\lib" \
		"/LIBPATH:${SDKPath}\Lib"

.\obj:
	md obj

.\lib:
	md lib  
