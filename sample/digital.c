#ifdef shell
gcc -o ${0//.c/} $0 -lxbee
exit
}
#endif
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

/* this sample will output with the value read from digital 0 */

#include <stdio.h>
#include <stdlib.h>
#include <xbee.h>

int main(int argc, char *argv[]) {
  xbee_con *con;
  xbee_pkt *pkt;
  double voltage;
  int i;

  /* setup libxbee */
  if (xbee_setup("/dev/ttyUSB0",57600) == -1) {
    return 1;
  }

  /* get a connection to the remote XBee */
  con = xbee_newcon('I',xbee_64bitIO,   0x0013A200, 0x40081826);

  /* do this forever! */
  while (1) {
    /* get as many packets as we can */
    while ((pkt = xbee_getpacket(con)) != NULL) {
      for (i = 0; i < pkt->samples; i++) {
        /* did we get a value for D0? */
        if (!xbee_hasdigital(pkt,i,0)) {
          /* there was no data for A0 in the packet */
          printf("D0: -- No Data --\n");
          continue;
        }
        /* print out the reading */
        printf("D0: %d\n",xbee_getdigital(pkt,i,0));
        fflush(stdout);
      }
      /* release the packet */
      free(pkt);
    }
    usleep(100);
  }

  return 0;
}
