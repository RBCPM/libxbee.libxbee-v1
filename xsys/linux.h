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
/* ### Linux Code ################################################## */
/* ################################################################# */

/*  this file contains code that is used by Linux ONLY */
#ifndef __GNUC__
#error "This file should only be used on a Linux system"
#endif

#define xbee_thread_create(a,b,c) pthread_create(&(a),NULL,(void *(*)(void *))(b),(void *)&(c))
#define xbee_thread_kill(a,b)     pthread_kill((a),(b))

#define xbee_mutex_init(a)        pthread_mutex_init(&(a),NULL)
#define xbee_mutex_destroy(a)     pthread_mutex_destroy(&(a))
#define xbee_mutex_lock(a)        pthread_mutex_lock(&(a))
#define xbee_mutex_unlock(a)      pthread_mutex_unlock(&(a))

#define xbee_write(a,b)           fwrite((a),1,(b),xbee.tty)
#define xbee_read(a,b)            fread((a),1,(b),xbee.tty)
