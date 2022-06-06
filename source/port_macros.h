/**
 * @file port_macros.h
 * @author your name (you@domain.com)
 * @brief 
 * @version 0.1
 * @date 2022-06-14
 * 
 * @copyright Copyright (c) 2022
 * 
 */

#ifndef __PORT_MACROS_H
#define __PORT_MACROS_H

#include "common_macros.h"

#define FUNC_ON_FLASH       ICACHE_FLASH_ATTR
#define FUNC_ON_RAM         
#define VAR_ON_FLASH        ICACHE_RODATA_ATTR
#define VAR_ON_IRAM         



#endif