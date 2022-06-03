/**
 * @file main.c
 * @author Tieu Tuan Bao (tieutuanbao@gmail.com)
 * @brief 
 * @version 0.1
 * @date 2022-01-30
 * 
 * @copyright Copyright (c) 2022
 * 
 */
#include "osapi.h"
#include "eagle_soc.h"
#include "ets_sys.h"
#include "user_interface.h"
#include "port_macro.h"

#include "main.h"

#include "espconn.h"
#include "esp8266_peri.h"
#include "esp8266_gpio.h"

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
void FUNC_ON_FLASH setup() {
    system_print_meminfo();

    esp_gpio_config(GPIO_PIN_14, GPIO_MODE_OUT_PP);
    esp_gpio_config(GPIO_PIN_13, GPIO_MODE_OUT_PP);
    esp_gpio_config(GPIO_PIN_12, GPIO_MODE_OUT_PP);
    esp_gpio_config(GPIO_PIN_15, GPIO_MODE_OUT_PP); 
}

void FUNC_ON_FLASH loop(os_event_t *events) {
    
    /* Không xóa hàm này */
    system_os_post(1, 0, 0);
}

uint32_t get_tick(void) {
    uint32_t tick;
    asm("rsr %0, ccount" : "=r" (tick));
    return tick;
}