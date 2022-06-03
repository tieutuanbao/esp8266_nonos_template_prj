# brief:		Makefile cho esp8266
# author:		Tiêu Tuấn Bảo
# create at:	22/04/2022

APP_NAME	:= template_project

# Cấu hình cho Compiler
SDK_BASE	?= ESP8266_NONOS_SDK/
ESPTOOL		?= tools/
XTENSA_DIR	?= C:/Espressif/xtensa-lx106-elf/bin/
CC			:= $(XTENSA_DIR)xtensa-lx106-elf-gcc
LD			:= $(XTENSA_DIR)xtensa-lx106-elf-gcc
AR			:= $(XTENSA_DIR)xtensa-lx106-elf-ar
OBJCOPY		:= $(XTENSA_DIR)xtensa-lx106-elf-objcopy
ADDR2LINE	:= $(XTENSA_DIR)xtensa-lx106-elf-addr2line

# Cấu hình cổng com
SERIAL_BAUD	:= 115200

# Cấu hình cổng nạp
FLASH_PORT	:= COM4
FLASH_BAUD	:= 921600
FLASHDEF	:= --flash_freq 80m --flash_mode qio --flash_size 32m

# Add source và include vào project
SRCS		:= source/rf_init.c
SRCS		+= source/main.c
SRCS		+= mcu_libs_BitsCat/arch/tensilica/l106/esp8266/driver/esp8266_gpio.c

INC			:= $(SDK_BASE)include
INC			+= $(SDK_BASE)driver_lib/include
INC			+= $(SDK_BASE)third_party/include
INC			+= $(SDK_BASE)third_party/include/lwip
INC			+= $(SDK_BASE)third_party/include/lwip/app
INC			+= ./source
INC			+= ./mcu_libs_BitsCat/arch/tensilica/l106/esp8266/driver/include
INC			+= ./mcu_libs_BitsCat/misc

# Define
DEFINE		:= ICACHE_FLASH
DEFINE		+= SPI_FLASH_SIZE_MAP=4
DEFINE		+= MEM_DEFAULT_USE_DRAM
DEFINE		+= LWIP_OPEN_SRC
DEFINE		+= MEMLEAK_DEBUG

# Đường dẫn lưu các file sau build
OBJS_DIR	:= build/obj/
BIN_DIR		:= build/bin/
OUT_DIR		:= build/out/


CFLAGS 		= -Os -g -Wpointer-arith -Wundef -Werror -Wl,-EL -fno-inline-functions -nostdlib \
				-mlongcalls -mtext-section-literals -ffunction-sections -fdata-sections \
				-fno-builtin-printf

# Linker
# LD_SCRIPT	= $(SDK_BASE)ld/eagle.app.v6.ld
LD_SCRIPT	= ld/eagle.app.v6.4M.ld
LDFLAGS		= -nostdlib -Wl,--no-check-sections -Wl,--gc-sections -u call_user_start -Wl,-static -Wl,--start-group

# Flag cho Compiler
SDK_LIBS 	:=	-L$(SDK_BASE)lib\
 				-T$(LD_SCRIPT)	\
				$(LDFLAGS)		\
				-lc				\
				-lgcc			\
				-lhal			\
				-lphy			\
				-lpp    		\
				-lnet80211    	\
				-llwip    		\
				-lwpa    		\
				-lcrypto    	\
				-lmain    		\
				-ljson    		\
				-lssl    		\
				-lupgrade    	\
				-lsmartconfig 	\
				-lairkiss


all: $(APP_NAME).bin

$(APP_NAME).bin: $(APP_NAME).out
	@echo ".bin to .out!"
	$(OBJCOPY) --only-section .text -O binary $(OUT_DIR)$< eagle.app.v6.text.bin
	$(OBJCOPY) --only-section .data -O binary $(OUT_DIR)$< eagle.app.v6.data.bin
	$(OBJCOPY) --only-section .rodata -O binary $(OUT_DIR)$< eagle.app.v6.rodata.bin
	$(OBJCOPY) --only-section .irom0.text -O binary $(OUT_DIR)$< eagle.app.v6.irom0text.bin
	$(ESPTOOL)gen_appbin $(OUT_DIR)$< 0 0 15 4 0
	@mv eagle.app.* $(BIN_DIR)
	@mv $(BIN_DIR)eagle.app.flash.bin $(BIN_DIR)$(APP_NAME)0x00000.bin
	@mv $(BIN_DIR)eagle.app.v6.irom0text.bin $(BIN_DIR)$(APP_NAME)0x10000.bin
	@echo "Generate $(APP_NAME)*.bin successully in folder $(BIN_DIR)."
	@echo "$(BIN_DIR)$(APP_NAME)0x00000.bin ------------> 0x00000"
	@echo "$(BIN_DIR)$(APP_NAME)0x10000.bin ------------> 0x10000"
# esptool\esptool.py merge_bin --output fileoutput --flash_freq 80m --flash_mode dio --flash_size 4MB 0x00000 build\bin\eagle.app.v6.irom0text.bin 
# $(ESPTOOL) elf2image $(FLASHDEF) $(OUT_DIR)main.out -o $(BIN_DIR)$(APP_NAME)
# @echo "Generate $(APP_NAME)*.bin successully in folder $(BIN_DIR)."
# @echo "$(BIN_DIR)$(APP_NAME)0x00000.bin ------------> 0x00000"
# @echo "$(BIN_DIR)$(APP_NAME)0x10000.bin ------------> 0x10000"
	
$(APP_NAME).out: $(APP_NAME).a
	$(LD) $(SDK_LIBS) $(OUT_DIR)$< -Wl,--end-group -o $(OUT_DIR)$@

# Tạo main.a từ tất cả các file .o trong $(OBJS_DIR)
$(APP_NAME).a: $(patsubst  %.c, %.o, $(SRCS)) $(patsubst  %.S, %.o, $(SRCS))
	$(AR) ru $(OUT_DIR)$@ $(wildcard $(OBJS_DIR)*.o)

# Tạo file module file.o từ file.c
%.o: $(or %.c,%.s)
	@mkdir -p $(OBJS_DIR)
	@mkdir -p $(BIN_DIR)
	@mkdir -p $(OUT_DIR)
	$(CC) $(CFLAGS) $(addprefix -D,$(DEFINE)) $(addprefix -I,$(INC)) -o $(OBJS_DIR)$(notdir $@) -c $<
	@echo "Build project done!"

# Clean project
clean:
	rm -rf build

# Nạp chương trình
flash:
	$(ESPTOOL)esptool -p $(FLASH_PORT) \
	--baud $(FLASH_BAUD) \
	write_flash $(FLASHDEF) \
	0x00000 $(BIN_DIR)$(APP_NAME)0x00000.bin \
	0x10000 $(BIN_DIR)$(APP_NAME)0x10000.bin
	
# Un-Brick
unbrick:
	$(ESPTOOL)esptool -p $(FLASH_PORT) \
	--baud $(FLASH_BAUD) \
	write_flash --flash_freq 40m --flash_mode qio --flash_size 32m \
	0x000000 $(SDK_BASE)bin/boot_v1.7.bin \
	0x3FB000 $(SDK_BASE)bin/blank.bin \
	0x3FC000 $(SDK_BASE)bin/esp_init_data_default_v08.bin \
	0x3FE000 $(SDK_BASE)bin/blank.bin \
	0x07E000 $(SDK_BASE)bin/blank.bin

# monitor
monitor:
	@python $(ESPTOOL)idf_monitor.py --port /dev/$(FLASH_PORT) --baud $(SERIAL_BAUD) $(OUT_DIR)$(APP_NAME).out

# Không cần quan tâm
.PHONY: all clean flash unbrick monitor