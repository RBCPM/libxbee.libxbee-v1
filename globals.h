/*
    libxbee - a C library to aid the use of Digi's Series 1 XBee modules
              running in API mode (AP=2).

    Copyright (C) 2009  Attie Grande (attie@attie.co.uk)

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

#include <stdio.h>
#include <stdlib.h>

#include <stdarg.h>

#include <string.h>
#include <fcntl.h>
#include <errno.h>
#include <signal.h>

/* #################### */
#ifdef __GNUC__ /* ---- */

#include <unistd.h>
#include <termios.h>
#include <pthread.h>
#include <sys/time.h>

#define xbee_thread_create(a,b,c) pthread_create(&(a),NULL,(void *(*)(void *))(b),(void *)&(c))
#define xbee_thread_kill(a,b)     pthread_kill((a),(b))

#define xbee_mutex_init(a)        pthread_mutex_init(&(a),NULL)
#define xbee_mutex_destroy(a)     pthread_mutex_destroy(&(a))
#define xbee_mutex_lock(a)        pthread_mutex_lock(&(a))
#define xbee_mutex_unlock(a)      pthread_mutex_unlock(&(a))

#define xbee_write(a,b)           fwrite((a),1,(b),xbee.tty)
#define xbee_read(a,b)            fread((a),1,(b),xbee.tty)

/* #################### */
#else           /* ---- */

#include <Windows.h>
#include <io.h>
#include <time.h>

/* this uses miliseconds not microseconds... */
#define usleep(a)                 Sleep((a)/1000)

#define xbee_thread_create(a,b,c) (((a) = CreateThread(NULL,0,(void *)(b),(void *)&(c),0,NULL)) == NULL)
#define xbee_thread_kill(a,b)     TerminateThread((a),(b))

#define xbee_mutex_init(a)        (((a) = CreateSemaphore(NULL, 1, 1, NULL)) == NULL)
#define xbee_mutex_destroy(a)     CloseHandle((a))
#define xbee_mutex_lock(a)        WaitForSingleObject((a),INFINITE)
#define xbee_mutex_unlock(a)      ReleaseSemaphore((a),1,NULL)

#if defined(_MSC_VER) || defined(_MSC_EXTENSIONS)
  #define DELTA_EPOCH_IN_MICROSECS  11644473600000000Ui64
#else
  #define DELTA_EPOCH_IN_MICROSECS  11644473600000000ULL
#endif

struct timezone {
  int  tz_minuteswest; /* minutes W of Greenwich */
  int  tz_dsttime;     /* type of dst correction */
};


/* #################### */
#endif          /* ---- */

#include "xbee.h"

