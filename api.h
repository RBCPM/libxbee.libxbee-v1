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

#define TRUE 1
#define FALSE 0

#define ISREADY					  \
  if (!xbee_ready) {				  \
    fprintf(stderr,"XBee: Run xbee_setup() first!...\n"); \
    exit(1);					  \
  }

#define M8(x) (x & 0xFF)
#define FDO(x,y,z)				\
  if (((x) = fdopen((y),(z))) == NULL) {	\
    perror("fopen()");				\
    return(-1);					\
  }
#define FO(x,y,z)				\
  if (((x) = open((y),(z))) == -1) {		\
    perror("open()");				\
    return(-1);					\
  }

struct t_data {
  unsigned char data[128];
  unsigned int length;
};
typedef struct t_data t_data;

struct t_info {
  int i;
};
typedef struct t_info t_info;

struct {
  xbee_con *conlist;
  pthread_mutex_t conmutex;

  xbee_pkt *pktlist;
  pthread_mutex_t pktmutex;

  pthread_mutex_t sendmutex;

  pthread_t listent;

  xbee_con *con_txStatus;

  int ttyfd;
  FILE *tty;

  int logfd;
  FILE *log;

  char *path;
} xbee;

static void *Xmalloc(size_t size);
static void *Xrealloc(void *ptr, size_t size);
#define Xfree(x) Xfree2((void **)&x)
static void Xfree2(void **ptr);

static int xbee_parse_io(xbee_pkt *p, unsigned char *d, int offset, int i);
static void xbee_listen_wrapper(t_info *info);
static int xbee_listen(t_info *info);
static unsigned char xbee_getByte(void);
static unsigned char xbee_getRawByte(void);
static int xbee_matchpktcon(xbee_pkt *pkt, xbee_con *con);

static t_data *xbee_make_pkt(unsigned char *data, int len);
static void xbee_send_pkt(t_data *pkt);
