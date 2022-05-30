# Project folder lập trình cho ESP8266
# 1 - Cài đặt Espressif-ESP8266-DevKit: 
https://drive.google.com/file/d/1CxqOpOEMuMxV0w9KvOLlhyYrsts05btK/view?usp=sharing
# 2 - Cài đặt MSYS2, và làm theo hướng dẫn để cài các package (make, gcc) theo các bước (1-9) (Chỉ cần làm đến bước 7):
https://www.msys2.org/
# 3 - Clone Example Project:
https://github.com/tieutuanbao/esp8266_example_project.git
# 4 - Chạy các lệnh sau:
- cd esp8266_example_project
- git clone https://github.com/espressif/ESP8266_NONOS_SDK.git
- git clone https://github.com/tieutuanbao/mcu_libs_BitsCat.git
# 5 - Cấu hình các thông số cần thiết trong makefile:

# 6 - Compile và Nạp:
- Sử dụng git bash để chạy lệnh:
    + make clean        // Clean project
    + make              // Build project
    + make flash        // Nạp chương trình vào esp, cấu hình cổng COM trong makefile trước khi nạp
    + make unbrick      // Unbrick project trong trường hợp trước đó esp đã nạp code arduino