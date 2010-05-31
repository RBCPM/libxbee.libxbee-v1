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

#include "linux.h"

static int xbee_select(struct timeval *timeout) {
  fd_set fds;

  FD_ZERO(&fds);
  FD_SET(xbee.ttyfd, &fds);

  return select(xbee.ttyfd+1, &fds, NULL, NULL, timeout);
}
