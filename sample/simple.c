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

#include <stdio.h>
#include <stdlib.h>
#include <xbee.h>

int main(int argc, char *argv[]) {
  xbee_con *con;
  xbee_pkt *pkt, *rpkt;

  /* setup the xbee */
  if (xbee_setup("/dev/ttyUSB0",57600) == -1) {
    /* oh no... it failed */
    printf("xbee_setup() failed...\n");
    exit(1);
  }

  /* setup a connection */
  con = xbee_newcon('I',xbee_64bitData, 0x0013A200, 0x40081826);

  /* just wait for data, and echo it back! */
  while (1) {
    /* while there are packets avaliable... */
    while ((pkt = xbee_getpacket(con)) != NULL) {
      /* print the recieved data */
      printf("Rx: %s\n",pkt->data);
      /* say thank you */
      rpkt = xbee_senddata(con,"thank you for saying '%s'\r",pkt->data);
      /* free the packet */
      free(pkt);
      /* was a packet returned? */
      if (rpkt) {
        /* check the response status */
        if (rpkt->status != 0) {
          /* uhoh... */
          printf("An error occured while sending (0x%02X)\n",rpkt->status);
          free(rpkt);
          exit(1);
        }
        /* free the packet */
        free(rpkt);
      }
    }
    usleep(100000);
  }

  /* not that we'll ever get here but... */
  return 0;
}

