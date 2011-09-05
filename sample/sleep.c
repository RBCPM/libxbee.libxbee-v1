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

/* this sample will show you how to make a connection sleep */
/* a connection will remain sleeping until it recieves a packet...
   putting a connection to sleep, allows you to create a second
     connection to the same remote XBee
   the most recently created connection will always recieve the packets
   if the only connection to a remote XBee is sleeping when data is recieved
     it will be woken up. */

#include <stdio.h>
#include <stdlib.h>
#include <signal.h>
#include <xbee.h>

void sighandler(int sig) {
  xbee_pkt *pkt;
  if (sig == SIGINT) {
    xbee_end();
    exit(0);
  }
}

void callback1(xbee_con *con, xbee_pkt *pkt) {
  printf("Rx1: %s\n",pkt->data);
}
void callback2(xbee_con *con, xbee_pkt *pkt) {
  printf("Rx2: %s\n",pkt->data);
}

int main(int argc, char *argv[]) {
  xbee_con *con;
  xbee_con *con2;
  xbee_pkt *pkt, *rpkt;

  /* setup the xbee */
  if (xbee_setuplog("/dev/ttyUSB0",57600,2) == -1) {
    /* oh no... it failed */
    printf("xbee_setup() failed...\n");
    exit(1);
  }

  /* handle ^C */
  signal(SIGINT, sighandler);

  /* setup a connection */
  con = xbee_newcon('I',xbee_64bitData, 0x0013A200, 0x40081826);
  con->callback = callback1;

  printf("Waiting...\n");

  /* do nothing forever! */
  for (;;) {
    printf("Con1 Awake!\n");
    con->sleeping = 0;
    sleep(10); /* 10 sec */
    printf("Con1 Sleeping... Con2 created!\n");
    con->sleeping = 1;
    con2 = xbee_newcon('I',xbee_64bitData, 0x0013A200, 0x40081826);
    if (!con2) {
      printf("Error making con2...\n");
      continue;
    }
    con2->callback = callback2;
    sleep(10);
    printf("Con2 destroyed... Con1 still sleeping...\n");
    xbee_endcon(con2);
    sleep(10);
  }

  /* shouldn't ever get here but... */
  return 0;
}

