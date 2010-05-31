#-- uncomment this to enable debugging
#DEBUG:=/Zi /DDEBUG

#-- you may need to edit these lines if your installation is different
VCPath:=C:\Program Files (x86)\Microsoft Visual Studio 9.0\VC
SDKPath:=C:\Program Files\Microsoft SDKs\Windows\v6.0A


###### YOU SHOULD NOT CHANGE BELOW THIS LINE ######

SRCS:=api.c

CC:="${VCPath}\bin\cl.exe"
LINK:="${VCPath}\bin\link.exe"
RC:="${SDKPath}\bin\rc.exe"

.PHONY: all new clean 

all: .\lib\libxbee.dll

new: clean all

clean:
	rmdir /Q /S lib
	rmdir /Q /S obj
	del .\xsys\win32.res

.\lib\libxbee.dll: .\lib .\obj\api.obj .\xsys\win32.res
	${LINK} /nologo /DLL /MAP:lib\libxbee.map /DEF:xsys\win32.def "/LIBPATH:${SDKPath}\Lib" "/LIBPATH:${VCPath}\lib" /OUT:.\lib\libxbee.dll .\obj\api.obj .\xsys\win32.res

.\obj\api.obj: .\obj api.c api.h xbee.h
	${CC} ${DEBUG} /nologo "/I${SDKPath}\Include" "/I${VCPath}\include" /MT /Ox /Gz /c /Fo.\obj\api.obj ${SRCS}

.\xsys\win32.res: .\xsys\win32.rc
	${RC} "/I${SDKPath}\Include" "/I${VCPath}\include" /n .\xsys\win32.rc 

.\obj:
	md obj

.\lib:
	md lib  
