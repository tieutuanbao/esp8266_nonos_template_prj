#include "osapi.h"
#include "mem.h"
#include "eagle_soc.h"
#include "ets_sys.h"
#include "user_interface.h"
#include "common_macros.h"

#include "main.h"

/**
 * @brief ----------- Define -----------
 *
 */

/**
 * @brief ----------- Typedef -----------
 *
 */

/**
 * @brief ----------- Variable -----------
 *
 */

/**
 * @brief ----------- Prototype -----------
 *
 */
uint32_t get_tick(void);

/**
 * @brief ----------- User code -----------
 *
 */

/**
 * @brief Setup
 * 
 */
ICACHE_FLASH_ATTR void setup() {
    system_print_meminfo();
}

/**
 * @brief loop
 * 
 */
ICACHE_FLASH_ATTR void loop(os_event_t *events) {

    /* Không xóa hàm này */
    system_os_post(1, 0, 0);
}

uint32_t get_tick(void) {
    uint32_t tick;
    asm("rsr %0, ccount" : "=r" (tick));
    return tick;
}