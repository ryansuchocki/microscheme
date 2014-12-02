#include <stdint.h>

uint16_t myfunc(uint16_t x, uint16_t y, uint16_t z) {
  if (x + y < 2) return 0;
  if (x + y < 4) return 1;
  if (x + y < 6) return z;
}


