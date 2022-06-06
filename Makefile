# brief:		Makefile cho esp8266
# author:		Tiêu Tuấn Bảo
# create at:	22/04/2022

APP_NAME	:= sample_project

# Cấu hình cho Compiler
SDK_BASE	?= ESP8266_NONOS_SDK/
ESPTOOL		?= tools/esptool/esptool.py
MONITORTOOL	?= tools/idf_monitor.py
GENAPPTOOL	?= tools/gen_appbin.py
XTENSA_DIR	?= C:/msys32/opt/xtensa-lx106-elf/bin/
CC			:= $(XTENSA_DIR)xtensa-lx106-elf-gcc
LD			:= $(XTENSA_DIR)xtensa-lx106-elf-gcc
AR			:= $(XTENSA_DIR)xtensa-lx106-elf-ar
OBJCOPY		:= $(XTENSA_DIR)xtensa-lx106-elf-objcopy
OBJDUMP		:= $(XTENSA_DIR)xtensa-lx106-elf-objdump
ADDR2LINE	:= $(XTENSA_DIR)xtensa-lx106-elf-addr2line


# Cấu hình cổng com
SERIAL_BAUD	:= 115200

# Cấu hình cổng nạp
FLASH_PORT	:= COM4
FLASH_BAUD	:= 921600
FLASHDEF	:= --flash_freq 80m --flash_mode qio --flash_size 4MB --compress

# Add source và include vào project
SRCS		:= ./source/rf_init.c
SRCS		+= ./source/main.c
SRCS		+= ./mcu_xlibs/misc/bits_string.c
SRCS		+= ./mcu_xlibs/arch/tensilica/l106/esp8266/driver/esp8266_gpio.c
SRCS		+= ./mcu_xlibs/arch/tensilica/l106/esp8266/driver/esp8266_iomux.c
SRCS		+= ./mcu_xlibs/arch/tensilica/l106/esp8266/driver/esp8266_i2s.c
SRCS		+= ./mcu_xlibs/arch/tensilica/l106/esp8266/driver/esp8266_slc.c
SRCS		+= ./mcu_xlibs/arch/tensilica/l106/esp8266/libs/esp8266_wifi/esp8266_wifi_scan.c

INC			:= $(SDK_BASE)include
INC			+= $(SDK_BASE)driver_lib/include
INC			+= $(SDK_BASE)third_party/include
INC			+= $(SDK_BASE)third_party/include/lwip/app
INC			+= $(SDK_BASE)third_party/include/lwip
INC			+= ./source
INC			+= ./mcu_xlibs
INC			+= ./mcu_xlibs/misc
INC			+= ./mcu_xlibs/arch/tensilica/l106/esp8266/include/driver
INC			+= ./mcu_xlibs/arch/tensilica/l106/esp8266/libs/esp8266_wifi
INC			+= ./mcu_xlibs/arch/tensilica/l106/esp8266/libs/dns_server
INC			+= ./mcu_xlibs/arch/tensilica/l106/esp8266/libs/i2s_dma

# Define
DEFINE		:= ICACHE_FLASH
DEFINE		+= SPI_FLASH_SIZE_MAP=4
DEFINE		+= MEM_DEFAULT_USE_DRAM
DEFINE		+= LWIP_OPEN_SRC

# Đường dẫn lưu các file sau build
OBJS_DIR	:= build/obj/
BIN_DIR		:= build/bin/
OUT_DIR		:= build/out/

OBJS		:= $(addprefix $(OBJS_DIR), $(patsubst  %.c, %.o, $(notdir $(SRCS))))
DATETIME	:= $(shell date "+%Y-%b-%d_%H:%M:%S_%Z")


CCFLAGS :=	-Os	\
			-g \
			-Wpointer-arith \
			-Wundef \
			-Wl,-EL \
			-fno-inline-functions \
			-nostdlib \
			-mlongcalls	\
			-mtext-section-literals \
			-ffunction-sections \
			-fdata-sections	\
			-fno-builtin-printf \
			-DICACHE_FLASH \
			-DBUID_TIME=\"$(DATETIME)\"

# Linker
LD_SCRIPT	= $(SDK_BASE)ld/eagle.app.v6.ld
# LD_SCRIPT	= ld/eagle.app.v6.4M.ld
LDFLAGS		= -Wl,--no-check-sections -Wl,--gc-sections -u call_user_start -Wl,-static

# Flag cho Compiler
SDK_LIBS 	:=	-L$(SDK_BASE)lib		\
				-nostdlib				\
				-T$(LD_SCRIPT)			\
				$(LDFLAGS)				\
				-Wl,--start-group		\
				-lc    				\
				-lgcc    			\
				-lhal				\
				-lphy				\
				-lpp    			\
				-lnet80211    		\
				-llwip	    		\
				-lmbedtls			\
				-lwpa    			\
				-lcrypto    		\
				-lmain    			\
				-ljson    			\
				-lssl    			\
				-lupgrade    		\
				-lsmartconfig 		\
				-lairkiss			\
				-ldriver
				


all: $(APP_NAME).bin

$(APP_NAME).bin: $(APP_NAME).out
	@echo ""
	@mkdir -p $(BIN_DIR)
	@rm -f -r $(BIN_DIR)eagle.S $(BIN_DIR)eagle.dump
	$(OBJDUMP) -x -s $(OUT_DIR)$< > $(BIN_DIR)eagle.dump
	$(OBJDUMP) -S $(OUT_DIR)$< > $(BIN_DIR)eagle.S
	@echo ""
	$(OBJCOPY) --only-section .text -O binary $(OUT_DIR)$< eagle.app.v6.text.bin
	$(OBJCOPY) --only-section .data -O binary $(OUT_DIR)$< eagle.app.v6.data.bin
	$(OBJCOPY) --only-section .rodata -O binary $(OUT_DIR)$< eagle.app.v6.rodata.bin
	$(OBJCOPY) --only-section .irom0.text -O binary $(OUT_DIR)$< eagle.app.v6.irom0text.bin
	@echo ""
	@python $(GENAPPTOOL) $(OUT_DIR)$< 0 0 15 6 0
	@mv eagle.app.* $(BIN_DIR)
	@mv $(BIN_DIR)eagle.app.flash.bin $(BIN_DIR)$(APP_NAME)0x00000.bin
	@mv $(BIN_DIR)eagle.app.v6.irom0text.bin $(BIN_DIR)$(APP_NAME)0x10000.bin
	@echo "Generate $(APP_NAME)*.bin successully in folder $(BIN_DIR)."
	@echo "$(BIN_DIR)$(APP_NAME)0x00000.bin ------------> 0x00000"
	@echo "$(BIN_DIR)$(APP_NAME)0x10000.bin ------------> 0x10000"
	
$(APP_NAME).out: $(APP_NAME).a
	$(LD) $(SDK_LIBS) $(OUT_DIR)$< -Wl,--end-group -o $(OUT_DIR)$@

# Tạo main.a từ tất cả các file .o trong $(OBJS_DIR)
$(APP_NAME).a: $(patsubst  %.c, %.o, $(SRCS))
	@mkdir -p $(OUT_DIR)
	$(AR) ru $(OUT_DIR)$@ $(OBJS)

# Tạo file module file.o từ file.c
%.o: $(or %.c,%.s)
	@mkdir -p $(OBJS_DIR)
	$(CC) $(CCFLAGS) $(addprefix -D,$(DEFINE)) $(addprefix -I,$(INC)) -o $(OBJS_DIR)$(notdir $@) -c $<

# Clean project
clean:
	rm -rf build

# Nạp chương trình
flash:
	@python $(ESPTOOL) --chip esp8266 --port $(FLASH_PORT) --baud $(FLASH_BAUD) --before default_reset --after hard_reset \
	write_flash $(FLASHDEF) \
	0x00000 $(BIN_DIR)$(APP_NAME)0x00000.bin \
	0x10000 $(BIN_DIR)$(APP_NAME)0x10000.bin \
	0x3FC000 $(SDK_BASE)bin/esp_init_data_default_v08.bin
	
# Un-Brick
unbrick:
	@python $(ESPTOOL) -p $(FLASH_PORT) \
	--baud $(FLASH_BAUD) \
	write_flash $(FLASHDEF) \
	0x000000 $(SDK_BASE)bin/boot_v1.7.bin \
	0x3FB000 $(SDK_BASE)bin/blank.bin \
	0x3FC000 $(SDK_BASE)bin/esp_init_data_default_v08.bin \
	0x3FD000 $(SDK_BASE)bin/blank.bin \
	0x3FE000 $(SDK_BASE)bin/blank.bin \
	0x07E000 $(SDK_BASE)bin/blank.bin

# monitor
monitor:
	python $(MONITORTOOL) --port $(FLASH_PORT) --baud $(SERIAL_BAUD) $(OUT_DIR)$(APP_NAME).out
# Không cần quan tâm
.PHONY: all clean flash unbrick monitor