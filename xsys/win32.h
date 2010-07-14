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

/* ################################################################# */
/* ### Win32 Code ################################################## */
/* ################################################################# */

/*  this file contains code that is used by Win32 ONLY */
#ifndef _WIN32
#error "This file should only be used on a Win32 system"
#endif

#pragma comment(lib, "Advapi32.lib")
#pragma comment(lib, "User32.lib")

#define dllid   "attie-co-uk.libxbee"
#define dlldesc "libxbee - XBee API Library"
/* libxbee's GUID is {7A6E25AA-ECB5-4370-87B5-A1D31840FE23} */
#define dllGUID "{7A6E25AA-ECB5-4370-87B5-A1D31840FE23}"

HMODULE glob_hModule = NULL;

/* this uses miliseconds not microseconds... */
#define usleep(a)                 Sleep((a)/1000)

#define xbee_thread_create(a,b,c) (((a) = CreateThread(NULL,0,(void *)(b),(void *)&(c),0,NULL)) == NULL)
#define xbee_thread_kill(a,b)     TerminateThread((a),(b))

#define xbee_mutex_init(a)        (((a) = CreateSemaphore(NULL, 1, 1, NULL)) == NULL)
#define xbee_mutex_destroy(a)     CloseHandle((a))
#define xbee_mutex_lock(a)        WaitForSingleObject((a),INFINITE)
#define xbee_mutex_unlock(a)      ReleaseSemaphore((a),1,NULL)

#define xbee_close(a)             CloseHandle((a))

typedef struct win32_callback_info win32_callback_info;
struct win32_callback_info {
  xbee_con *con;
  HWND hWnd;
  UINT uMsg;
  win32_callback_info *next;
};

win32_callback_info *callbackMap = NULL;
HANDLE callbackmutex;
