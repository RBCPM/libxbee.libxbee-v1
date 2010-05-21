#-- uncomment this to enable debugging
#DEBUG:=/Zi
ProgFiles32bit:=Program Files (x86)
#ProgFiles32bit:=Program Files

###### YOU SHOULD NOT CHANGE BELOW THIS LINE ######


SRCS:=api.c

CC:="C:\Program Files (x86)\Microsoft Visual Studio 9.0\VC\bin\cl.exe"

all: .\obj .\lib
	${CC} \
		${DEBUG} \
		/nologo \
		/MT \
		/Ox \
		/Gz \
		"/IC:\Program Files\Microsoft SDKs\Windows\v6.0A\Include" \
		"/IC:\${ProgFiles32bit}\Microsoft Visual Studio 9.0\VC\include" \
		/Fo.\obj\libxbee.obj \
		/Fe.\lib\libxbee.dll \
		api.c \
		/LD \
		/link \
		/MAP:lib\libxbee.map \
		"/DEF:win32.def" \
		"/LIBPATH:C:\Program Files\Microsoft SDKs\Windows\v6.0A\Lib" \
		"/LIBPATH:C:\${ProgFiles32bit}\Microsoft Visual Studio 9.0\VC\lib"

.\obj:
	md obj

.\lib:
	md lib
