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

/* this sample will setup certain AT parameters of the local XBee unit */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <xbee.h>

int setAT(xbee_con *con, char *cmd, char *parameter, char **str) {
  xbee_pkt *pkt;
  char *tmp;
  if (strlen(cmd) != 2) {
    printf("Invalid command: \"%s\"\n",cmd);
    return -1;
  }
  if (parameter == NULL) {
    xbee_senddata(con,"%s",cmd);
  } else {
    xbee_senddata(con,"%s%s",cmd,parameter);
  }
  pkt = xbee_getpacketwait(con);
  if (pkt == NULL) {
    printf("Failed to set NI!\n");
    return -2;
  }
  if (pkt->status != 0) {
    printf("An error occured while setting NI!\n");
    return -3;
  }
  if (pkt->datalen > 0) {
    int i;
    *str = realloc(*str,sizeof(char) * (pkt->datalen + 1));
    memcpy(*str,pkt->data,pkt->datalen);
    (*str)[pkt->datalen] = '\0';
    return pkt->datalen;
  }
  return 0;
}

int main(int argc, char *argv[]) {
  xbee_con *con;
  int ret,i;
  char *str = NULL;

  if (argc != 2) {
    printf("Usage: %s <newname>\n",argv[0]);
    return 1;
  }

  /* setup libxbee */
  if (xbee_setup("/dev/ttyUSB0",57600) == -1) {
    printf("xbee_setup failed...\n");
    return 1;
  }

  /* create an AT connection */
  con = xbee_newcon('I',xbee_localAT);
  /*con = xbee_newcon('I',xbee_64bitRemoteAT,0x13A200,0x403CB26A);*/

  printf("Getting origional NI: ");
  if ((ret = setAT(con,"NI",NULL,&str)) < 0) return 1;
  if (ret > 0) {
    for (i = 0; i < ret; i++) {
      printf("%c",(str[i]>=32 && str[i]<=126)?str[i]:'.');
    }
    printf("\n");
  }
  
  printf("Setting NI to '%s': ",(argc!=2)?"MyNode":argv[1]);
  if ((ret = setAT(con,"NI",(argc!=2)?"MyNode":argv[1],&str)) < 0) return 1;
  printf("OK\n");
  
  printf("Getting new NI: ");
  if ((ret = setAT(con,"NI",NULL,&str)) < 0) return 1;
  if (ret > 0) {
    for (i = 0; i < ret; i++) {
      printf("%c",(str[i]>=32 && str[i]<=126)?str[i]:'.');
    }
    printf("\n");
  }
  
  return 0;
}
