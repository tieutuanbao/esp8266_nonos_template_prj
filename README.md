# Project folder lập trình cho ESP8266
# 1 - Download compiler và giải nén:
https://dl.espressif.com/dl/xtensa-lx106-elf-gcc8_4_0-esp-2020r3-win32.zip
# 2 - Cài đặt MSYS2, và làm theo hướng dẫn để cài các package (make, gcc) theo các bước (1-9) (Chỉ cần làm đến bước 7):
https://www.msys2.org/
# 3 - Clone Example Project:
https://github.com/tieutuanbao/esp8266_example_project.git
# 4 - Chạy các lệnh sau:
- cd esp8266_example_project
- git clone https://github.com/espressif/ESP8266_NONOS_SDK.git
- git clone https://github.com/tieutuanbao/mcu_libs_BitsCat.git
# 5 - Cấu hình các thông số cần thiết trong makefile:
XTENSA_DIR  : Compiler path : ${PATH_TO_COMPILER}/xtensa-lx106-elf/bin/
FLASH_PORT  : Cổng nạp
FLASH_BAUD  : Tốc độ nạp
FLASHDEF    : Cấu hình Flash
SERIAL_BAUD : Tốc độ serial
SRCS        : Những files .c hoặc .s
INC         : Đường dẫn đến file .h
DEFINE      : preprocessor
# 6 - Compile và Nạp:
- make clean        // Clean project
- make              // Build project
- make flash        // Nạp chương trình vào esp, cấu hình cổng COM trong makefile trước khi nạp
- make unbrick      // Unbrick project trong trường hợp trước đó esp đã nạp code arduino
- ./makefile.cmd    // Thay cho [make clean && make && make flash && make monitor], (!!! dùng cho windows)