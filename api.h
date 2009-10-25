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

  int ttyfd;
  FILE *tty;

  char *path;
} xbee;

#define MAX_PACKETS 1024

void *Xmalloc(size_t size);
void *Xrealloc(void *ptr, size_t size);
#define Xfree(x) Xfree2((void **)&x)
void Xfree2(void **ptr);

void xbee_listen(t_info *info);
unsigned char xbee_getByte(void);
unsigned char xbee_getRawByte(void);

t_data *xbee_make_pkt(unsigned char *data, int len);
void xbee_send_pkt(t_data *pkt);
