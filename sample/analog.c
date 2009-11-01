#ifdef shell
gcc -o ${0//.c/} $0 -lxbee
exit;
}
#endif

#include <stdio.h>
#include <stdlib.h>
#include <xbee.h>

/* set this to the voltage measured between GND and Vref - 3.3 is a good place to start */
#define Vref 3.3

int main(int argc, char *argv[]) {
  xbee_con *con;
  xbee_pkt *pkt;
  double voltage;

  /* setup libxbee */
  if (xbee_setup("/dev/ttyUSB0",57600) == -1) {
    return 1;
  }

  /* get a connection to the remote XBee */
  con = xbee_newcon('I',xbee_64bitIO,   0x0013A200, 0x403af247);

  /* do this forever! */
  while (1) {
    /* get as many packets as we can */
    while ((pkt = xbee_getpacket(con)) != NULL) {
      /* did we get a value for A0? */
      if (pkt->IOmask & 0x0200) {
        /* calculate the volcate */
        voltage = (Vref / 1024) * pkt->IOanalog[0];
        /* print out the reading */
        printf("\rA0: %.2fv ",voltage);
        fflush(stdout);
      }
      /* release the packet */
      free(pkt);
    }
    usleep(100);
  }

  return 0;
}
