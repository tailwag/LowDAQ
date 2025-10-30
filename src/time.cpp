#include "stm32g4xx_hal.h"
#include <sys/time.h>

extern "C" int _gettimeofday(struct timeval *tv, void *tzvp) {
    if (!tv) return -1;
    uint32_t ms = HAL_GetTick();
    tv->tv_sec = ms / 1000;
    tv->tv_usec = (ms % 1000) * 1000;
    return 0;
}