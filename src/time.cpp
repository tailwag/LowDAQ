#ifdef ARDUINO_NUCLEO_H753ZI
#include "stm32h7xx_hal.h"
#endif

#ifdef ARDUINO_NUCLEO_G474RE
#include "stm32g4xx_hal.h"
#endif

#ifdef ARDUINO_NUCLEO_F401RE
#include "stm32f4xx_hal.h"
#endif

#ifdef ARDUINO_NUCLEO_G0B1RE
#include "stm32g0xx_hal.h"
#endif 

#include <sys/time.h>

extern "C" int _gettimeofday(struct timeval *tv, void *tzvp) {
    if (!tv) return -1;
    uint32_t ms = HAL_GetTick();
    tv->tv_sec = ms / 1000;
    tv->tv_usec = (ms % 1000) * 1000;
    return 0;
}
