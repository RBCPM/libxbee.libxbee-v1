#include <stdio.h>
#include <stdlib.h>
#include <stdarg.h>
#include <unistd.h>
#include <string.h>
#include <fcntl.h>
#include <termios.h>

#include <errno.h>

#include <pthread.h>

#include <sys/types.h>
#include <sys/ipc.h>
#include <sys/shm.h>
#include <sys/stat.h>

#include "xbee.h"

#define TRUE 1
#define FALSE 0

#define M8(x) (x & 0xFF)
#define FDO(x,y,z)				\
  if (((x) = fdopen((y),(z))) == NULL) {	\
    perror("fopen()");				\
    exit(1);					\
  }
#define FO(x,y,z)				\
  if (((x) = open((y),(z))) == -1) {		\
    perror("open()");				\
    exit(1);					\
  }
