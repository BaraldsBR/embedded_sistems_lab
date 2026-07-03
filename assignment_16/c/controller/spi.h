#ifndef SPI
#define SPI

#include <stdint.h>

typedef struct _spi_content_t {
  int16_t pitch;
  int16_t yaw;
} spi_content_t;

typedef struct _pos_rad {
  double pitch;
  double yaw;
} pos_rad;

int spiOpen(unsigned spiChan, unsigned spiBaud, unsigned spiFlags);
int spiClose(int fd);

int spiXfer(int fd, unsigned speed, void *txBuf, void *rxBuf, unsigned count);

#endif
